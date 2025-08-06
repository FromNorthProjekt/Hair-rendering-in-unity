using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using System.Linq;

/// <summary>
/// A sophisticated texture merger tool for Unity that allows combining N number of textures
/// with multi-channel mapping, blending controls, and flexible output path options.
/// This version includes robust validation and stable UI rendering to prevent GUILayout errors.
/// </summary>
public class TextureMerger : EditorWindow
{
    // --- Data Structures ---
    private List<Texture2D> inputTextures = new List<Texture2D>();
    private List<ChannelMapping> channelMappings = new List<ChannelMapping>();
    private Texture2D outputTexture;

    // --- UI State ---
    private Vector2 scrollPosition;
    private bool saveInSourceFolder = true;
    private string customSavePath = "Assets/MergedTexture.png";

    // --- Enums ---
    [System.Flags]
    private enum Channel { R = 1, G = 2, B = 4, A = 8 }
    private enum BlendMode { Normal_Overwrite, Multiply, Add, Screen, Overlay, Darken, Lighten };

    private class ChannelMapping
    {
        public int textureIndex;
        public Channel sourceChannels = Channel.R;
        public Channel destChannels = Channel.R;
        public BlendMode blendMode = BlendMode.Normal_Overwrite;
    }

    [MenuItem("North Projekt/Texture Merger")]
    public static void ShowWindow()
    {
        GetWindow<TextureMerger>("Texture Merger");
    }

    private void OnGUI()
    {
        scrollPosition = EditorGUILayout.BeginScrollView(scrollPosition);

        EditorGUILayout.LabelField("1. Input Textures", EditorStyles.boldLabel);
        DrawInputTexturesGUI();

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("2. Channel Mapping Rules", EditorStyles.boldLabel);
        DrawChannelMappingsGUI();

        EditorGUILayout.Space();
        EditorGUILayout.LabelField("3. Output File Path", EditorStyles.boldLabel);
        DrawOutputPathGUI();

        EditorGUILayout.Space();

        // --- Validation and Generate Button ---
        string validationError = GetValidationError();
        bool isInvalid = !string.IsNullOrEmpty(validationError);

        if (isInvalid)
        {
            EditorGUILayout.HelpBox(validationError, MessageType.Error);
        }

        EditorGUI.BeginDisabledGroup(isInvalid);
        if (GUILayout.Button("Generate Merged Texture", GUILayout.Height(40)))
        {
            GenerateTexture();
        }
        EditorGUI.EndDisabledGroup();

        // --- Output Preview and Save ---
        if (outputTexture != null)
        {
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("4. Output Preview & Save", EditorStyles.boldLabel);
            Rect previewRect = GUILayoutUtility.GetRect(128, 128, GUILayout.ExpandWidth(true), GUILayout.ExpandHeight(false));
            EditorGUI.DrawPreviewTexture(previewRect, outputTexture, null, ScaleMode.ScaleToFit);

            if (GUILayout.Button("Save Texture"))
            {
                SaveTexture();
            }
        }

        EditorGUILayout.EndScrollView();
    }

    #region GUI Drawing Methods
    private void DrawInputTexturesGUI()
    {
        int indexToRemove = -1; // Defer removal to after the loop

        for (int i = 0; i < inputTextures.Count; i++)
        {
            EditorGUILayout.BeginHorizontal();
            inputTextures[i] = (Texture2D)EditorGUILayout.ObjectField($"Texture {i}", inputTextures[i], typeof(Texture2D), false);
            if (GUILayout.Button("X", GUILayout.Width(25)))
            {
                indexToRemove = i; // Flag this index for removal
            }
            EditorGUILayout.EndHorizontal();
        }

        if (indexToRemove != -1)
        {
            inputTextures.RemoveAt(indexToRemove);
            channelMappings.RemoveAll(mapping => mapping.textureIndex == indexToRemove);
            foreach (var mapping in channelMappings)
            {
                if (mapping.textureIndex > indexToRemove)
                {
                    mapping.textureIndex--;
                }
            }
            Repaint();
        }

        if (GUILayout.Button("Add Input Texture"))
        {
            inputTextures.Add(null);
        }
    }

    private void DrawChannelMappingsGUI()
    {
        int indexToRemove = -1; // Defer removal to after the loop

        for (int i = 0; i < channelMappings.Count; i++)
        {
            EditorGUILayout.BeginVertical(EditorStyles.helpBox);
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField($"Rule {i + 1}", EditorStyles.boldLabel);
            if (GUILayout.Button("X", GUILayout.Width(25)))
            {
                indexToRemove = i; // Flag this index for removal
            }
            EditorGUILayout.EndHorizontal();

            channelMappings[i].textureIndex = EditorGUILayout.Popup("Source Texture", channelMappings[i].textureIndex, GetTextureNames());
            channelMappings[i].sourceChannels = (Channel)EditorGUILayout.EnumFlagsField("Get Channel(s)", channelMappings[i].sourceChannels);
            channelMappings[i].destChannels = (Channel)EditorGUILayout.EnumFlagsField("Put in Channel(s)", channelMappings[i].destChannels);
            channelMappings[i].blendMode = (BlendMode)EditorGUILayout.EnumPopup("Using Blend Mode", channelMappings[i].blendMode);
            EditorGUILayout.EndVertical();
            EditorGUILayout.Space();
        }

        if (indexToRemove != -1)
        {
            channelMappings.RemoveAt(indexToRemove);
            Repaint();
        }

        if (GUILayout.Button("Add Channel Mapping Rule"))
        {
            channelMappings.Add(new ChannelMapping());
        }
    }

    private void DrawOutputPathGUI()
    {
        // ** ROBUST UI FIX **
        // Manually create a horizontal layout to prevent the label and toggle from ever overlapping.
        EditorGUILayout.BeginHorizontal();
        var toggleContent = new GUIContent("Save in First Texture's Folder", "If checked, the output file will be saved in the same directory as the first input texture.");
        EditorGUILayout.LabelField(toggleContent);
        saveInSourceFolder = EditorGUILayout.Toggle(saveInSourceFolder, GUILayout.Width(20));
        EditorGUILayout.EndHorizontal();


        if (!saveInSourceFolder)
        {
            EditorGUILayout.BeginHorizontal();
            customSavePath = EditorGUILayout.TextField("Custom Path", customSavePath);
            if (GUILayout.Button("Browse...", GUILayout.Width(75)))
            {
                string path = EditorUtility.SaveFilePanelInProject("Select Save Location", "MergedTexture", "png", "Please select a save location");
                if (!string.IsNullOrEmpty(path))
                {
                    customSavePath = path;
                }
            }
            EditorGUILayout.EndHorizontal();
        }
    }
    #endregion

    #region Core Logic
    private void GenerateTexture()
    {
        Dictionary<string, bool> originalReadWriteStates = new Dictionary<string, bool>();
        try
        {
            foreach (var tex in inputTextures.Where(t => t != null))
            {
                SetTextureReadable(tex, true, originalReadWriteStates);
            }

            Texture2D firstTex = inputTextures[0];
            int width = firstTex.width;
            int height = firstTex.height;

            outputTexture = new Texture2D(width, height, TextureFormat.RGBA32, true);
            Color[] outputPixels = new Color[width * height];
            for (int i = 0; i < outputPixels.Length; i++)
            {
                outputPixels[i] = new Color(0, 0, 0, 1);
            }

            foreach (var mapping in channelMappings)
            {
                Texture2D sourceTex = inputTextures[mapping.textureIndex];
                List<Channel> sources = EnumToChannelList(mapping.sourceChannels);
                List<Channel> dests = EnumToChannelList(mapping.destChannels);

                for (int y = 0; y < height; y++)
                {
                    for (int x = 0; x < width; x++)
                    {
                        float u = (float)x / (width - 1);
                        float v = (float)y / (height - 1);
                        Color sourcePixel = sourceTex.GetPixelBilinear(u, v);
                        int pixelIndex = y * width + x;

                        for (int i = 0; i < sources.Count; i++)
                        {
                            float sourceValue = GetChannelValue(sourcePixel, sources[i]);
                            float destValue = GetChannelValue(outputPixels[pixelIndex], dests[i]);
                            float blendedValue = Blend(sourceValue, destValue, mapping.blendMode);
                            SetChannelValue(ref outputPixels[pixelIndex], dests[i], blendedValue);
                        }
                    }
                }
            }

            outputTexture.SetPixels(outputPixels);
            outputTexture.Apply();
        }
        finally
        {
            foreach (var entry in originalReadWriteStates)
            {
                string path = entry.Key;
                bool originalState = entry.Value;
                TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
                if (importer != null && importer.isReadable != originalState)
                {
                    importer.isReadable = originalState;
                    importer.SaveAndReimport();
                }
            }
        }
    }

    private void SaveTexture()
    {
        if (outputTexture == null)
        {
            EditorUtility.DisplayDialog("Error", "No texture to save. Please generate a texture first.", "OK");
            return;
        }

        string path;
        if (saveInSourceFolder)
        {
            string sourcePath = AssetDatabase.GetAssetPath(inputTextures[0]);
            string directory = Path.GetDirectoryName(sourcePath);
            path = Path.Combine(directory, "MergedTexture.png");
            path = AssetDatabase.GenerateUniqueAssetPath(path);
        }
        else
        {
            path = customSavePath;
        }

        if (string.IsNullOrEmpty(path)) return;

        byte[] bytes = outputTexture.EncodeToPNG();
        File.WriteAllBytes(path, bytes);
        AssetDatabase.Refresh();

        TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
        if (importer != null)
        {
            importer.isReadable = true;
            importer.SaveAndReimport();
        }
        Debug.Log($"Texture saved to {path}");
        EditorUtility.DisplayDialog("Success", $"Texture saved to:\n{path}", "OK");
    }
    #endregion

    #region Helpers and Validation
    private string GetValidationError()
    {
        if (inputTextures.Count == 0) return "Add at least one input texture.";

        for (int i = 0; i < inputTextures.Count; i++)
        {
            if (inputTextures[i] == null) return $"Input Texture slot {i} is empty. Please assign a texture or remove the slot.";
        }

        int firstWidth = inputTextures[0].width;
        int firstHeight = inputTextures[0].height;
        for (int i = 1; i < inputTextures.Count; i++)
        {
            if (inputTextures[i].width != firstWidth || inputTextures[i].height != firstHeight)
            {
                return $"Dimension mismatch: '{inputTextures[0].name}' is {firstWidth}x{firstHeight}, but '{inputTextures[i].name}' is {inputTextures[i].width}x{inputTextures[i].height}. All textures must have the same dimensions.";
            }
        }

        if (channelMappings.Count == 0) return "Add at least one channel mapping rule.";

        var usedTextureIndices = new HashSet<int>();
        var destinationTracker = new Dictionary<int, Channel>();

        for (int i = 0; i < channelMappings.Count; i++)
        {
            var mapping = channelMappings[i];
            usedTextureIndices.Add(mapping.textureIndex);

            if (mapping.sourceChannels == 0) return $"Rule {i + 1} is invalid: 'Get Channel(s)' cannot be 'Nothing'.";
            if (mapping.destChannels == 0) return $"Rule {i + 1} is invalid: 'Put in Channel(s)' cannot be 'Nothing'.";

            if (CountSetFlags(mapping.sourceChannels) != CountSetFlags(mapping.destChannels))
            {
                return $"Rule {i + 1} is invalid: The number of 'Get' channels must match the number of 'Put' channels.";
            }

            if (!destinationTracker.ContainsKey(mapping.textureIndex))
            {
                destinationTracker[mapping.textureIndex] = 0;
            }

            if ((destinationTracker[mapping.textureIndex] & mapping.destChannels) != 0)
            {
                return $"Ambiguous mapping in Rule {i + 1}: You are trying to write to a destination channel that is already being written to by another rule using '{inputTextures[mapping.textureIndex].name}'.";
            }
            destinationTracker[mapping.textureIndex] |= mapping.destChannels;
        }

        for (int i = 0; i < inputTextures.Count; i++)
        {
            if (!usedTextureIndices.Contains(i))
            {
                return $"Input Texture {i} ('{inputTextures[i].name}') is not used in any rule. Please use it or remove it.";
            }
        }

        return null; // No error
    }

    private void SetTextureReadable(Texture2D texture, bool readable, Dictionary<string, bool> originalStates)
    {
        string path = AssetDatabase.GetAssetPath(texture);
        if (string.IsNullOrEmpty(path)) return;

        TextureImporter importer = AssetImporter.GetAtPath(path) as TextureImporter;
        if (importer != null)
        {
            if (!originalStates.ContainsKey(path))
            {
                originalStates.Add(path, importer.isReadable);
            }

            if (importer.isReadable != readable)
            {
                importer.isReadable = readable;
                importer.SaveAndReimport();
            }
        }
    }

    private int CountSetFlags(Channel c)
    {
        int count = 0;
        if (c.HasFlag(Channel.R)) count++;
        if (c.HasFlag(Channel.G)) count++;
        if (c.HasFlag(Channel.B)) count++;
        if (c.HasFlag(Channel.A)) count++;
        return count;
    }

    private List<Channel> EnumToChannelList(Channel c)
    {
        var list = new List<Channel>();
        if (c.HasFlag(Channel.R)) list.Add(Channel.R);
        if (c.HasFlag(Channel.G)) list.Add(Channel.G);
        if (c.HasFlag(Channel.B)) list.Add(Channel.B);
        if (c.HasFlag(Channel.A)) list.Add(Channel.A);
        return list;
    }

    private string[] GetTextureNames()
    {
        return inputTextures.Select((tex, i) => (tex != null) ? $"Texture {i} ({tex.name})" : $"Texture {i} (Not Set)").ToArray();
    }

    private float GetChannelValue(Color color, Channel channel)
    {
        switch (channel)
        {
            case Channel.R: return color.r;
            case Channel.G: return color.g;
            case Channel.B: return color.b;
            case Channel.A: return color.a;
            default: return 0;
        }
    }

    private void SetChannelValue(ref Color color, Channel channel, float value)
    {
        switch (channel)
        {
            case Channel.R: color.r = value; break;
            case Channel.G: color.g = value; break;
            case Channel.B: color.b = value; break;
            case Channel.A: color.a = value; break;
        }
    }

    private float Blend(float source, float dest, BlendMode mode)
    {
        switch (mode)
        {
            case BlendMode.Normal_Overwrite: return source;
            case BlendMode.Multiply: return source * dest;
            case BlendMode.Add: return Mathf.Min(source + dest, 1.0f);
            case BlendMode.Screen: return 1 - (1 - source) * (1 - dest);
            case BlendMode.Overlay: return dest < 0.5f ? 2 * source * dest : 1 - 2 * (1 - source) * (1 - dest);
            case BlendMode.Darken: return Mathf.Min(source, dest);
            case BlendMode.Lighten: return Mathf.Max(source, dest);
            default: return source;
        }
    }
    #endregion
}