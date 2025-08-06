// LitRW_CustomGUI.cs
using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;
using System;

public class LitRW_CustomGUI : ShaderGUI
{
    // Properties
    private MaterialProperty baseMapProp, baseColorProp, cutoffProp;
    private MaterialProperty uiRoughnessProp, roughnessMapProp, shaderSmoothnessProp;
    private MaterialProperty metallicProp, metallicMapProp;
    private MaterialProperty specColorProp, urpSpecGlossMapProp;
    private MaterialProperty bumpMapProp, bumpScaleProp;
    private MaterialProperty parallaxMapProp, parallaxScaleProp;
    private MaterialProperty occlusionMapProp, occlusionStrengthProp;
    private MaterialProperty emissionMapProp, emissionColorProp;
    private MaterialProperty surfaceProp, blendProp, cullProp, alphaClipProp;
    private MaterialProperty srcBlendProp, dstBlendProp, zWriteProp;
    private MaterialProperty receiveShadowsProp, workflowModeProp;

    // Foldouts
    private static bool showSurfaceInputs = true;
    private static bool showWorkflowParams = true;
    private static bool showAdvancedOptions = true;

    // Internal
    private MaterialEditor materialEditor;
    private Material material;
    private static GUIStyle sectionHeaderStyle, sectionHeaderTextStyle, subHeaderStyle, richTextStyle;
    private bool stylesInitialized = false;

    private void InitializeStyles()
    {
        if (stylesInitialized) return;

        sectionHeaderStyle = new GUIStyle(GUI.skin.box);
        if (EditorGUIUtility.isProSkin) {
             sectionHeaderStyle.normal.background = EditorGUIUtility.Load("builtin skins/darkskin/images/projectbrowsericonareabg.png") as Texture2D;
        } else {
            sectionHeaderStyle.normal.background = EditorGUIUtility.Load("builtin skins/lightskin/images/collout_processed@2x.png") as Texture2D;
            if (sectionHeaderStyle.normal.background == null) sectionHeaderStyle.normal.background = EditorGUIUtility.whiteTexture;
        }
        sectionHeaderStyle.border = new RectOffset(2, 2, 2, 2);
        sectionHeaderStyle.margin = new RectOffset(0, 0, 5, 0);
        sectionHeaderStyle.padding = new RectOffset(0, 0, 0, 0);

        sectionHeaderTextStyle = new GUIStyle(EditorStyles.foldout);
        sectionHeaderTextStyle.fontSize = 13;
        sectionHeaderTextStyle.fontStyle = FontStyle.Bold;
        sectionHeaderTextStyle.fixedHeight = EditorGUIUtility.singleLineHeight + 2;
        sectionHeaderTextStyle.contentOffset = new Vector2(0, 1);
        
        subHeaderStyle = new GUIStyle(EditorStyles.label)
        {
            fontSize = 11,
            fontStyle = FontStyle.Bold,
            padding = new RectOffset(5, 0, 3, 3)
        };
        richTextStyle = new GUIStyle(EditorStyles.label) { richText = true, padding = new RectOffset(5, 0, 0, 0) };

        stylesInitialized = true;
    }

    public void FindProperties(MaterialProperty[] props)
    {
        baseMapProp = FindProperty("_BaseMap", props);
        baseColorProp = FindProperty("_BaseColor", props);
        cutoffProp = FindProperty("_Cutoff", props);
        uiRoughnessProp = FindProperty("_Roughness", props);
        roughnessMapProp = FindProperty("_RoughnessMap", props);
        shaderSmoothnessProp = FindProperty("_Smoothness", props);
        metallicProp = FindProperty("_Metallic", props);
        metallicMapProp = FindProperty("_MetallicMap", props);
        specColorProp = FindProperty("_SpecColor", props, false);
        urpSpecGlossMapProp = FindProperty("_SpecGlossMap", props, false);
        bumpMapProp = FindProperty("_BumpMap", props);
        bumpScaleProp = FindProperty("_BumpScale", props);
        parallaxMapProp = FindProperty("_ParallaxMap", props);
        parallaxScaleProp = FindProperty("_Parallax", props);
        occlusionMapProp = FindProperty("_OcclusionMap", props);
        occlusionStrengthProp = FindProperty("_OcclusionStrength", props);
        emissionMapProp = FindProperty("_EmissionMap", props);
        emissionColorProp = FindProperty("_EmissionColor", props);
        surfaceProp = FindProperty("_Surface", props, false);
        blendProp = FindProperty("_Blend", props, false);
        cullProp = FindProperty("_Cull", props);
        alphaClipProp = FindProperty("_AlphaClip", props);
        srcBlendProp = FindProperty("_SrcBlend", props, false);
        dstBlendProp = FindProperty("_DstBlend", props, false);
        zWriteProp = FindProperty("_ZWrite", props);
        receiveShadowsProp = FindProperty("_ReceiveShadows", props);
        workflowModeProp = FindProperty("_WorkflowMode", props, false);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        this.materialEditor = materialEditor;
        this.material = materialEditor.target as Material;

        InitializeStyles();
        FindProperties(props);

        DrawSurfaceInputs();
        DrawWorkflowParameters();
        DrawAdvancedOptions();

        if (GUI.changed)
        {
            foreach (var obj in materialEditor.targets)
                MaterialChanged((Material)obj);
        }

        EditorGUILayout.Space();
        materialEditor.RenderQueueField();
    }

    private void DrawSectionHeader(string title, ref bool foldoutState)
    {
        Rect headerRect = EditorGUILayout.GetControlRect(false, sectionHeaderTextStyle.fixedHeight + 2);
        GUI.Box(headerRect, GUIContent.none, sectionHeaderStyle);
        Rect foldoutRect = new Rect(
            headerRect.x + 4,
            headerRect.y + (headerRect.height - sectionHeaderTextStyle.fixedHeight) / 2,
            headerRect.width - 8,
            sectionHeaderTextStyle.fixedHeight
        );
        foldoutState = EditorGUI.Foldout(foldoutRect, foldoutState, title, true, sectionHeaderTextStyle);
        if (foldoutState)
        {
            EditorGUILayout.Space(2);
        }
    }
    
    private void BeginSectionContent()
    {
        EditorGUI.indentLevel++;
        EditorGUILayout.BeginVertical(EditorStyles.helpBox);
        EditorGUILayout.Space(2);
    }

    private void EndSectionContent()
    {
        EditorGUILayout.Space(2);
        EditorGUILayout.EndVertical();
        EditorGUI.indentLevel--;
        EditorGUILayout.Space(5);
    }

    private void DrawSurfaceInputs()
    {
        DrawSectionHeader("Surface Inputs", ref showSurfaceInputs);
        if (showSurfaceInputs)
        {
            BeginSectionContent();
            
            // ==================================================================
            // THIS IS THE CORRECTED CODE
            // Step 1: Draw the texture and color on one line.
            materialEditor.TexturePropertySingleLine(new GUIContent("Albedo (RGB) Alpha (A)"), baseMapProp, baseColorProp);
            
            // Step 2: Draw the Tiling and Offset fields for the texture on the next line.
            materialEditor.TextureScaleOffsetProperty(baseMapProp);
            // ==================================================================

            materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map"), bumpMapProp, bumpScaleProp);
            materialEditor.TexturePropertySingleLine(new GUIContent("Parallax Map (A)"), parallaxMapProp, parallaxScaleProp);
            materialEditor.TexturePropertySingleLine(new GUIContent("Occlusion Map (R)"), occlusionMapProp, occlusionStrengthProp);
            
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Emission", subHeaderStyle);
            EditorGUI.indentLevel++; 
            bool emissionEnabled = material.IsKeywordEnabled("_EMISSION");
            EditorGUI.BeginChangeCheck();
            emissionEnabled = EditorGUILayout.Toggle("Enable Emission", emissionEnabled);
            if (EditorGUI.EndChangeCheck())
            {
                SetKeyword(material, "_EMISSION", emissionEnabled);
            }
            if (emissionEnabled)
            {
                materialEditor.TexturePropertySingleLine(new GUIContent("Emission Map (RGB)"), emissionMapProp, emissionColorProp);
            }
            EditorGUI.indentLevel--; 
            EndSectionContent();
        }
    }

    private void DrawWorkflowParameters()
    {
        DrawSectionHeader("Workflow & PBR Parameters", ref showWorkflowParams);
        if (showWorkflowParams)
        {
            BeginSectionContent();

            if (workflowModeProp != null)
            {
                EditorGUI.BeginChangeCheck();
                string[] workflowNames = { "Specular", "Metallic" };
                int currentWorkflow = (int)workflowModeProp.floatValue;
                if (currentWorkflow < 0 || currentWorkflow >= workflowNames.Length) currentWorkflow = 1; 
                int newWorkflow = EditorGUILayout.Popup("Workflow Mode", currentWorkflow, workflowNames);
                if (EditorGUI.EndChangeCheck())
                {
                    workflowModeProp.floatValue = newWorkflow;
                    MaterialChanged(material);
                }
                EditorGUILayout.Space();
            }

            bool isSpecularWorkflow = workflowModeProp != null && workflowModeProp.floatValue == 0;

            if (!isSpecularWorkflow)
            {
                EditorGUILayout.LabelField("<b>Metallic Workflow</b>", richTextStyle);
                materialEditor.TexturePropertySingleLine(new GUIContent("Metallic Map (R)"), metallicMapProp, metallicProp);
            }
            else
            {
                EditorGUILayout.LabelField("<b>Specular Workflow</b>", richTextStyle);
                if (specColorProp != null && urpSpecGlossMapProp != null)
                {
                    materialEditor.TexturePropertySingleLine(new GUIContent("Specular Map (RGB) Smoothness (A)"), urpSpecGlossMapProp, specColorProp);
                }
                else if (specColorProp != null)
                {
                     materialEditor.ShaderProperty(specColorProp, "Specular Color");
                     EditorGUILayout.HelpBox("Shader uses a separate Roughness Map for smoothness in Specular mode.", MessageType.Info);
                }
                else
                {
                    EditorGUILayout.HelpBox("Shader is missing _SpecColor property for Specular workflow.", MessageType.Warning);
                }
            }

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("<b>Roughness / Smoothness</b>", richTextStyle);
            if (isSpecularWorkflow && urpSpecGlossMapProp != null && urpSpecGlossMapProp.textureValue != null)
            {
                 EditorGUILayout.HelpBox("Using separate Roughness Map. URP Lit Specular often uses Smoothness from SpecGlossMap Alpha.", MessageType.Info);
            }
            EditorGUI.BeginChangeCheck();
            materialEditor.TexturePropertySingleLine(new GUIContent("Roughness Map (R)"), roughnessMapProp, uiRoughnessProp);
            if (EditorGUI.EndChangeCheck())
            {
                UpdateSmoothnessFromUIRoughness();
            }
            
            EndSectionContent();
        }
    }
    
    private void UpdateSmoothnessFromUIRoughness()
    {
        if (material.HasProperty("_Roughness") && material.HasProperty("_Smoothness") && shaderSmoothnessProp != null && uiRoughnessProp != null)
        {
            float uiRoughnessValue = uiRoughnessProp.floatValue;
            shaderSmoothnessProp.floatValue = 1.0f - uiRoughnessValue;
        }
    }

    private void DrawAdvancedOptions()
    {
        DrawSectionHeader("Advanced Options", ref showAdvancedOptions);
        if (showAdvancedOptions)
        {
            BeginSectionContent();
            bool alphaClipEnabled = alphaClipProp.floatValue > 0.5f;
            EditorGUI.BeginChangeCheck();
            alphaClipEnabled = EditorGUILayout.Toggle("Alpha Clipping", alphaClipEnabled);
            if (EditorGUI.EndChangeCheck())
            {
                alphaClipProp.floatValue = alphaClipEnabled ? 1.0f : 0.0f;
                SetKeyword(material, "_ALPHATEST_ON", alphaClipEnabled);
            }
            if (alphaClipEnabled)
            {
                EditorGUI.indentLevel++;
                materialEditor.ShaderProperty(cutoffProp, "Cutoff");
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.Space();
            bool receiveShadowsEnabled = receiveShadowsProp.floatValue > 0.5f;
            EditorGUI.BeginChangeCheck();
            receiveShadowsEnabled = EditorGUILayout.Toggle("Receive Shadows", receiveShadowsEnabled);
            if (EditorGUI.EndChangeCheck())
            {
                receiveShadowsProp.floatValue = receiveShadowsEnabled ? 1.0f : 0.0f;
                SetKeyword(material, "_RECEIVE_SHADOWS_OFF", !receiveShadowsEnabled);
            }
            EditorGUILayout.Space();
            EditorGUILayout.LabelField("Surface Options", subHeaderStyle);
            EditorGUI.indentLevel++; 
            DoPopup(cullProp, "Culling Mode", Enum.GetNames(typeof(UnityEngine.Rendering.CullMode)), 
                (newVal) => MaterialChanged(material));
            if (surfaceProp != null)
                DoEnumPopup<SurfaceType>(surfaceProp, "Surface Type", 
                    (newVal) => MaterialChanged(material));
            if (surfaceProp != null && (SurfaceType)surfaceProp.floatValue == SurfaceType.Transparent && blendProp != null)
            {
                DoEnumPopup<BlendMode>(blendProp, "Blend Mode", 
                    (newVal) => MaterialChanged(material));
            }
            EditorGUI.indentLevel--; 
            EndSectionContent();
        }
    }

    private void DoEnumPopup<T>(MaterialProperty property, string label, Action<int> onChanged = null) where T : Enum
    {
        if (property == null) return;
        EditorGUI.showMixedValue = property.hasMixedValue;
        var prevValue = (int)property.floatValue;
        EditorGUI.BeginChangeCheck();
        T S = (T)EditorGUILayout.EnumPopup(label, (T)Enum.ToObject(typeof(T), prevValue));
        if (EditorGUI.EndChangeCheck())
        {
            property.floatValue = Convert.ToSingle(S);
            onChanged?.Invoke((int)property.floatValue);
        }
        EditorGUI.showMixedValue = false;
    }

    private void DoPopup(MaterialProperty property, string label, string[] options, Action<int> onChanged = null)
    {
        if (property == null) return;
        EditorGUI.showMixedValue = property.hasMixedValue;
        var prevValue = (int)property.floatValue;
        EditorGUI.BeginChangeCheck();
        int S = EditorGUILayout.Popup(label, prevValue, options);
        if (EditorGUI.EndChangeCheck())
        {
            property.floatValue = S;
            onChanged?.Invoke(S);
        }
        EditorGUI.showMixedValue = false;
    }

    public static void SetKeyword(Material mat, string keyword, bool state)
    {
        if (mat.IsKeywordEnabled(keyword) != state)
        {
            if (state)
                mat.EnableKeyword(keyword);
            else
                mat.DisableKeyword(keyword);
        }
    }

    public static void MaterialChanged(Material material)
    {
        if (material == null) throw new ArgumentNullException("material");

        bool alphaClip = material.HasProperty("_AlphaClip") && material.GetFloat("_AlphaClip") > 0.5f;
        SetKeyword(material, "_ALPHATEST_ON", alphaClip);

        bool receiveShadows = material.HasProperty("_ReceiveShadows") && material.GetFloat("_ReceiveShadows") > 0.5f;
        SetKeyword(material, "_RECEIVE_SHADOWS_OFF", !receiveShadows);
        
        if (material.HasProperty("_WorkflowMode"))
        {
            bool isSpecularWorkflow = material.GetFloat("_WorkflowMode") == 0; 
            SetKeyword(material, "_SPECULAR_SETUP", isSpecularWorkflow);
        }

        if (material.HasProperty("_BumpMap"))
            SetKeyword(material, "_NORMALMAP", material.GetTexture("_BumpMap") != null);
        
        if (material.HasProperty("_ParallaxMap"))
            SetKeyword(material, "_PARALLAXMAP", material.GetTexture("_ParallaxMap") != null);

        if (material.HasProperty("_OcclusionMap"))
            SetKeyword(material, "_OCCLUSIONMAP", material.GetTexture("_OcclusionMap") != null);
        
        if (material.HasProperty("_MetallicMap"))
            SetKeyword(material, "_METALLICMAP_ON", material.GetTexture("_MetallicMap") != null);
        
        if (material.HasProperty("_RoughnessMap"))
            SetKeyword(material, "_ROUGHNESSMAP_ON", material.GetTexture("_RoughnessMap") != null);
        
        SurfaceType surfaceType = material.HasProperty("_Surface") ? (SurfaceType)material.GetFloat("_Surface") : SurfaceType.Opaque;
        BlendMode blendMode = material.HasProperty("_Blend") ? (BlendMode)material.GetFloat("_Blend") : BlendMode.Alpha;
        SetupMaterialWithSurfaceType(material, surfaceType, (float)blendMode);
    }
    
    public enum SurfaceType { Opaque, Transparent }
    public enum BlendMode { Alpha, Premultiply, Additive, Multiply }

    public static void SetupMaterialWithSurfaceType(Material material, SurfaceType surfaceType, float blendModeValue)
    {
        material.SetFloat("_Surface", (float)surfaceType);
        switch (surfaceType)
        {
            case SurfaceType.Opaque:
                material.SetOverrideTag("RenderType", "Opaque");
                material.renderQueue = (int)RenderQueue.Geometry;
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 1);
                material.SetFloat("_AlphaToMask", 0.0f);
                SetKeyword(material, "_SURFACE_TYPE_TRANSPARENT", false);
                SetKeyword(material, "_ALPHAPREMULTIPLY_ON", false);
                SetKeyword(material, "_ALPHAMODULATE_ON", false);
                break;
            case SurfaceType.Transparent:
                material.SetOverrideTag("RenderType", "Transparent");
                material.renderQueue = (int)RenderQueue.Transparent;
                material.SetFloat("_AlphaToMask", 0.0f);
                SetKeyword(material, "_SURFACE_TYPE_TRANSPARENT", true);
                SetupMaterialWithBlendMode(material, (BlendMode)blendModeValue, true);
                break;
        }
    }

    public static void SetupMaterialWithBlendMode(Material material, BlendMode blendMode, bool isTransparentSurface)
    {
        if (!isTransparentSurface) return;
        material.SetFloat("_Blend", (float)blendMode);
        switch (blendMode)
        {
            case BlendMode.Alpha:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                SetKeyword(material, "_ALPHAPREMULTIPLY_ON", false);
                SetKeyword(material, "_ALPHAMODULATE_ON", false);
                break;
            case BlendMode.Premultiply:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                material.SetInt("_ZWrite", 0);
                SetKeyword(material, "_ALPHAPREMULTIPLY_ON", true);
                SetKeyword(material, "_ALPHAMODULATE_ON", false);
                break;
            case BlendMode.Additive:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_ZWrite", 0);
                SetKeyword(material, "_ALPHAPREMULTIPLY_ON", false);
                SetKeyword(material, "_ALPHAMODULATE_ON", false);
                break;
            case BlendMode.Multiply:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                material.SetInt("_ZWrite", 0);
                SetKeyword(material, "_ALPHAPREMULTIPLY_ON", false);
                SetKeyword(material, "_ALPHAMODULATE_ON", true);
                break;
        }
    }

    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)
    {
        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        if (material.HasProperty("_Surface")) material.SetFloat("_Surface", material.GetFloat("_Surface"));
        else if (surfaceProp != null) material.SetFloat("_Surface", (float)SurfaceType.Opaque);

        if (material.HasProperty("_Blend")) material.SetFloat("_Blend", material.GetFloat("_Blend"));
        else if (blendProp != null) material.SetFloat("_Blend", (float)BlendMode.Alpha);

        if (material.HasProperty("_Cull")) material.SetFloat("_Cull", material.GetFloat("_Cull"));
        else if (cullProp != null) material.SetFloat("_Cull", (float)UnityEngine.Rendering.CullMode.Back);

        if (material.HasProperty("_AlphaClip")) material.SetFloat("_AlphaClip", material.GetFloat("_AlphaClip"));
        else if (alphaClipProp != null) material.SetFloat("_AlphaClip", 0.0f);

        if (material.HasProperty("_ReceiveShadows")) material.SetFloat("_ReceiveShadows", material.GetFloat("_ReceiveShadows"));
        else if (receiveShadowsProp != null) material.SetFloat("_ReceiveShadows", 1.0f);

        if (material.HasProperty("_WorkflowMode"))
        {
            material.SetFloat("_WorkflowMode", material.GetFloat("_WorkflowMode"));
        } else if (workflowModeProp != null) {
            material.SetFloat("_WorkflowMode", 1.0f); 
        }
        
        if (material.HasProperty("_Roughness") && material.HasProperty("_Smoothness"))
        {
            float defaultUIRoughness = material.GetFloat("_Roughness");
            material.SetFloat("_Smoothness", 1.0f - defaultUIRoughness);
        }

        MaterialChanged(material);
    }
}