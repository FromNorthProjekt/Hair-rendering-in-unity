using UnityEngine;
using UnityEditor;

namespace RED.Editor.Inspectors.Shaders
{
    public class HairShaderGUI : ShaderGUI
    {
        private MaterialProperty _baseMap;
        private MaterialProperty _baseColor;
        private MaterialProperty _bumpMap;
        private MaterialProperty _bumpScale;
        private MaterialProperty _occlusionMap;
        private MaterialProperty _occlusionStrength;
        private MaterialProperty _useNoiseTexture;
        private MaterialProperty _noiseTexture;
        
        private MaterialProperty _rootColor;
        private MaterialProperty _lengthColor;
        private MaterialProperty _tipColor;
        private MaterialProperty _rootDistance;
        private MaterialProperty _rootFade;
        private MaterialProperty _tipDistance;
        private MaterialProperty _tipFade;
        
        private MaterialProperty _perStrandHueVariation;
        private MaterialProperty _perStrandHueVariationClean;
        private MaterialProperty _goingGrey;
        
        private MaterialProperty _smoothness;
        private MaterialProperty _fresnelStrength;
        private MaterialProperty _hairStrandDirection;
        private MaterialProperty _useCardNormals;
        
        private MaterialProperty _strandSeparation;
        private MaterialProperty _specularFocus;
        private MaterialProperty _rimLightStrength;
        private MaterialProperty _shadowContrast;
        private MaterialProperty _strandVisibility;
        private MaterialProperty _strandFrequency;
        private MaterialProperty _strandThreshold;
        
        private MaterialProperty _anisotropicPower;
        private MaterialProperty _anisotropicStrength;
        private MaterialProperty _anisotropicShift;
        private MaterialProperty _anisotropicColor;
        private MaterialProperty _secondarySpecularPower;
        private MaterialProperty _secondarySpecularStrength;
        private MaterialProperty _secondarySpecularShift;
        private MaterialProperty _secondarySpecularColor;
        private MaterialProperty _usePhysicalSpecularColors;
        
        private MaterialProperty _transmissionStrength;
        
        private MaterialProperty _alphaMode;
        private MaterialProperty _cutoff;
        private MaterialProperty _smoothDither;
        private MaterialProperty _ditherStrength;
        private MaterialProperty _useSeparateDepthCutoff;
        private MaterialProperty _depthCutoff;
        private MaterialProperty _cull;
        
        private bool _surfaceInputsFoldout = true;
        private bool _colorGradientFoldout = true;
        private bool _strandVariationFoldout = true;
        private bool _lightingFoldout = true;
        private bool _specularFoldout = true;
        private bool _transmissionFoldout = true;
        private bool _alphaModeFoldout = true;
        private bool _systemFoldout = true;

        public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
        {
            FindProperties(properties);
            
            // Ensure shader keywords are properly synchronized with material properties
            SyncShaderKeywords(materialEditor.target as Material);
            
            EditorGUILayout.LabelField("Hair Shader - North Projekt", EditorStyles.boldLabel);
            EditorGUILayout.Space();
            
            DrawSurfaceInputs(materialEditor);
            DrawColorGradient(materialEditor);
            DrawStrandVariation(materialEditor);
            DrawLighting(materialEditor);
            DrawSpecular(materialEditor);
            DrawTransmission(materialEditor);
            DrawAlphaMode(materialEditor);
            DrawSystemSettings(materialEditor);
        }
        
        private void FindProperties(MaterialProperty[] properties)
        {
            _baseMap = FindProperty("_BaseMap", properties);
            _baseColor = FindProperty("_BaseColor", properties);
            _bumpMap = FindProperty("_BumpMap", properties);
            _bumpScale = FindProperty("_BumpScale", properties);
            _occlusionMap = FindProperty("_OcclusionMap", properties);
            _occlusionStrength = FindProperty("_OcclusionStrength", properties);
            _useNoiseTexture = FindProperty("_UseNoiseTexture", properties);
            _noiseTexture = FindProperty("_NoiseTexture", properties);
            
            _rootColor = FindProperty("_Root_Color", properties);
            _lengthColor = FindProperty("_Length_Color", properties);
            _tipColor = FindProperty("_Tip_Color", properties);
            _rootDistance = FindProperty("_Root_Distance", properties);
            _rootFade = FindProperty("_Root_Fade", properties);
            _tipDistance = FindProperty("_Tip_Distance", properties);
            _tipFade = FindProperty("_Tip_Fade", properties);
            
            _perStrandHueVariation = FindProperty("_PerStrandHueVariation", properties);
            _perStrandHueVariationClean = FindProperty("_PerStrandHueVariationClean", properties);
            _goingGrey = FindProperty("_Going_Grey", properties);
            
            _smoothness = FindProperty("_Smoothness", properties);
            _fresnelStrength = FindProperty("_FresnelStrength", properties);
            _hairStrandDirection = FindProperty("_HairStrandDirection", properties);
            _useCardNormals = FindProperty("_UseCardNormals", properties);
            
            _strandSeparation = FindProperty("_StrandSeparation", properties);
            _specularFocus = FindProperty("_SpecularFocus", properties);
            _rimLightStrength = FindProperty("_RimLightStrength", properties);
            _shadowContrast = FindProperty("_ShadowContrast", properties);
            _strandVisibility = FindProperty("_StrandVisibility", properties);
            _strandFrequency = FindProperty("_StrandFrequency", properties);
            _strandThreshold = FindProperty("_StrandThreshold", properties);
            
            _anisotropicPower = FindProperty("_AnisotropicPower", properties);
            _anisotropicStrength = FindProperty("_AnisotropicStrength", properties);
            _anisotropicShift = FindProperty("_AnisotropicShift", properties);
            _anisotropicColor = FindProperty("_AnisotropicColor", properties);
            _secondarySpecularPower = FindProperty("_SecondarySpecularPower", properties);
            _secondarySpecularStrength = FindProperty("_SecondarySpecularStrength", properties);
            _secondarySpecularShift = FindProperty("_SecondarySpecularShift", properties);
            _secondarySpecularColor = FindProperty("_SecondarySpecularColor", properties);
            _usePhysicalSpecularColors = FindProperty("_UsePhysicalSpecularColors", properties);
            
            _transmissionStrength = FindProperty("_TransmissionStrength", properties);
            
            _alphaMode = FindProperty("_AlphaMode", properties);
            _cutoff = FindProperty("_Cutoff", properties);
            _smoothDither = FindProperty("_SmoothDither", properties);
            _ditherStrength = FindProperty("_DitherStrength", properties);
            _useSeparateDepthCutoff = FindProperty("_UseSeparateDepthCutoff", properties);
            _depthCutoff = FindProperty("_DepthCutoff", properties);
            _cull = FindProperty("_Cull", properties);
        }
        
        private void SyncShaderKeywords(Material material)
        {
            // Sync alpha mode keywords
            material.DisableKeyword("_ALPHAMODE_CLIP");
            material.DisableKeyword("_ALPHAMODE_CLIPWITHALPHA");
            material.DisableKeyword("_ALPHAMODE_ALPHA");
            
            int alphaMode = Mathf.RoundToInt(_alphaMode.floatValue);
            switch (alphaMode)
            {
                case 0:
                    material.EnableKeyword("_ALPHAMODE_CLIP");
                    break;
                case 1:
                    material.EnableKeyword("_ALPHAMODE_CLIPWITHALPHA");
                    break;
                case 2:
                    material.EnableKeyword("_ALPHAMODE_ALPHA");
                    break;
            }
            
            // Sync smooth dither keyword
            if (_smoothDither.floatValue > 0.5f)
            {
                material.EnableKeyword("_SMOOTH_DITHER_ON");
            }
            else
            {
                material.DisableKeyword("_SMOOTH_DITHER_ON");
            }
            
            // Sync noise texture keyword
            if (_useNoiseTexture.floatValue > 0.5f)
            {
                material.EnableKeyword("_NOISETEXTURE_ON");
            }
            else
            {
                material.DisableKeyword("_NOISETEXTURE_ON");
            }
            
            // Sync use card normals keyword
            if (_useCardNormals.floatValue > 0.5f)
            {
                material.EnableKeyword("_USE_CARD_NORMALS_ON");
            }
            else
            {
                material.DisableKeyword("_USE_CARD_NORMALS_ON");
            }
            
            // Sync physical specular colors keyword
            if (_usePhysicalSpecularColors.floatValue > 0.5f)
            {
                material.EnableKeyword("_USE_PHYSICAL_SPECULAR_COLORS");
            }
            else
            {
                material.DisableKeyword("_USE_PHYSICAL_SPECULAR_COLORS");
            }
            
            // Sync texture map keywords based on assigned textures
            // Normal Map
            if (_bumpMap.textureValue != null)
            {
                material.EnableKeyword("_NORMALMAP");
            }
            else
            {
                material.DisableKeyword("_NORMALMAP");
            }
            
            // Occlusion Map
            if (_occlusionMap.textureValue != null)
            {
                material.EnableKeyword("_OCCLUSIONMAP");
            }
            else
            {
                material.DisableKeyword("_OCCLUSIONMAP");
            }
        }
        
        private void DrawSurfaceInputs(MaterialEditor materialEditor)
        {
            _surfaceInputsFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_surfaceInputsFoldout, "Surface Inputs");
            if (_surfaceInputsFoldout)
            {
                EditorGUI.indentLevel++;
                materialEditor.TexturePropertySingleLine(new GUIContent("Base Map"), _baseMap, _baseColor);
                materialEditor.TexturePropertySingleLine(new GUIContent("Normal Map"), _bumpMap, _bumpScale);
                materialEditor.TexturePropertySingleLine(new GUIContent("Occlusion Map"), _occlusionMap, _occlusionStrength);
                
                EditorGUILayout.Space();
                
                Material material = materialEditor.target as Material;
                bool noiseEnabled = _useNoiseTexture.floatValue > 0.5f;
                EditorGUI.BeginChangeCheck();
                noiseEnabled = EditorGUILayout.Toggle("Enable Noise Variation", noiseEnabled);
                if (EditorGUI.EndChangeCheck())
                {
                    _useNoiseTexture.floatValue = noiseEnabled ? 1.0f : 0.0f;
                    
                    // Enable/disable the shader keyword
                    if (noiseEnabled)
                    {
                        material.EnableKeyword("_NOISETEXTURE_ON");
                    }
                    else
                    {
                        material.DisableKeyword("_NOISETEXTURE_ON");
                    }
                }
                
                if (noiseEnabled)
                {
                    materialEditor.TexturePropertySingleLine(new GUIContent("Noise Texture"), _noiseTexture);
                }
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
        
        private void DrawColorGradient(MaterialEditor materialEditor)
        {
            _colorGradientFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_colorGradientFoldout, "Color Gradient");
            if (_colorGradientFoldout)
            {
                EditorGUI.indentLevel++;
                materialEditor.ColorProperty(_rootColor, "Root Color");
                materialEditor.ColorProperty(_lengthColor, "Length Color");
                materialEditor.ColorProperty(_tipColor, "Tip Color");
                
                EditorGUILayout.Space();
                materialEditor.RangeProperty(_rootDistance, "Root Distance");
                materialEditor.RangeProperty(_rootFade, "Root Fade");
                materialEditor.RangeProperty(_tipDistance, "Tip Distance");
                materialEditor.RangeProperty(_tipFade, "Tip Fade");
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
        
        private void DrawStrandVariation(MaterialEditor materialEditor)
        {
            _strandVariationFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_strandVariationFoldout, "Strand Variation");
            if (_strandVariationFoldout)
            {
                EditorGUI.indentLevel++;
                
                EditorGUILayout.LabelField("Hue Variation", EditorStyles.boldLabel);
                materialEditor.RangeProperty(_perStrandHueVariationClean, "Per Strand Hue Variation");
                materialEditor.RangeProperty(_perStrandHueVariation, "Per Strand Hue Variation (Noise)");
                EditorGUILayout.HelpBox("Use the clean version for subtle, consistent hue shifts. Use the noise version for more random variation.", MessageType.Info);
                
                EditorGUILayout.Space();
                materialEditor.RangeProperty(_goingGrey, "Going Grey Threshold");
                
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
        
        private void DrawLighting(MaterialEditor materialEditor)
        {
            _lightingFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_lightingFoldout, "Kajiya-Kay Lighting");
            if (_lightingFoldout)
            {
                EditorGUI.indentLevel++;
                materialEditor.RangeProperty(_smoothness, "Smoothness");
                materialEditor.RangeProperty(_fresnelStrength, "Fresnel Strength");
                
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("Hair Quality Controls", EditorStyles.boldLabel);
                materialEditor.RangeProperty(_strandSeparation, "Strand Separation");
                materialEditor.RangeProperty(_specularFocus, "Specular Focus");
                materialEditor.RangeProperty(_rimLightStrength, "Rim Light Strength");
                materialEditor.RangeProperty(_shadowContrast, "Shadow Contrast");
                
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("Strand Definition", EditorStyles.boldLabel);
                materialEditor.RangeProperty(_strandVisibility, "Strand Visibility");
                materialEditor.RangeProperty(_strandFrequency, "Strand Frequency");
                materialEditor.RangeProperty(_strandThreshold, "Strand Threshold");
                
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("Hair Strand Direction", EditorStyles.boldLabel);
                
                // Use Card Normals toggle
                Material material = materialEditor.target as Material;
                bool useCardNormals = _useCardNormals.floatValue > 0.5f;
                EditorGUI.BeginChangeCheck();
                useCardNormals = EditorGUILayout.Toggle("Use Card Normals", useCardNormals);
                if (EditorGUI.EndChangeCheck())
                {
                    _useCardNormals.floatValue = useCardNormals ? 1.0f : 0.0f;
                    
                    // Enable/disable the shader keyword
                    if (useCardNormals)
                    {
                        material.EnableKeyword("_USE_CARD_NORMALS_ON");
                    }
                    else
                    {
                        material.DisableKeyword("_USE_CARD_NORMALS_ON");
                    }
                }
                
                // Hair Strand Direction (only show when not using card normals)
                if (!useCardNormals)
                {
                    materialEditor.VectorProperty(_hairStrandDirection, "Hair Strand Direction");
                    EditorGUILayout.HelpBox("Controls the direction of specular highlights. (0, -1, 0) = vertical, (1, 0, 0) = horizontal.", MessageType.Info);
                }
                else
                {
                    EditorGUILayout.HelpBox("Using card normals for automatic horizontal specular highlights.", MessageType.Info);
                }
                
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
        
        private void DrawSpecular(MaterialEditor materialEditor)
        {
            _specularFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_specularFoldout, "Anisotropic Specular");
            if (_specularFoldout)
            {
                EditorGUI.indentLevel++;
                
                // Physical vs Manual Specular Colors Toggle
                Material material = materialEditor.target as Material;
                bool usePhysicalColors = _usePhysicalSpecularColors.floatValue > 0.5f;
                EditorGUI.BeginChangeCheck();
                usePhysicalColors = EditorGUILayout.Toggle("Use Physical Specular Colors", usePhysicalColors);
                if (EditorGUI.EndChangeCheck())
                {
                    _usePhysicalSpecularColors.floatValue = usePhysicalColors ? 1.0f : 0.0f;
                    
                    // Enable/disable the shader keyword
                    if (usePhysicalColors)
                    {
                        material.EnableKeyword("_USE_PHYSICAL_SPECULAR_COLORS");
                    }
                    else
                    {
                        material.DisableKeyword("_USE_PHYSICAL_SPECULAR_COLORS");
                    }
                }
                
                if (usePhysicalColors)
                {
                    EditorGUILayout.HelpBox("Physical Mode: Primary specular uses light color, secondary uses hair albedo color.", MessageType.Info);
                }
                else
                {
                    EditorGUILayout.HelpBox("Manual Mode: Use custom colors from the inspector for both specular highlights.", MessageType.Info);
                }
                
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("Primary Anisotropic Specular", EditorStyles.boldLabel);
                materialEditor.RangeProperty(_anisotropicStrength, "Strength");
                materialEditor.RangeProperty(_anisotropicPower, "Power");
                materialEditor.RangeProperty(_anisotropicShift, "Shift");
                
                if (!usePhysicalColors)
                {
                    materialEditor.ColorProperty(_anisotropicColor, "Color");
                }
                
                EditorGUILayout.Space();
                EditorGUILayout.LabelField("Secondary Anisotropic Specular", EditorStyles.boldLabel);
                materialEditor.RangeProperty(_secondarySpecularStrength, "Strength");
                materialEditor.RangeProperty(_secondarySpecularPower, "Power");
                materialEditor.RangeProperty(_secondarySpecularShift, "Shift");
                
                if (!usePhysicalColors)
                {
                    materialEditor.ColorProperty(_secondarySpecularColor, "Color");
                }
                
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
        
        private void DrawTransmission(MaterialEditor materialEditor)
        {
            _transmissionFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_transmissionFoldout, "Transmission");
            if (_transmissionFoldout)
            {
                EditorGUI.indentLevel++;
                materialEditor.RangeProperty(_transmissionStrength, "Transmission Strength");
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
        
        private void DrawAlphaMode(MaterialEditor materialEditor)
        {
            _alphaModeFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_alphaModeFoldout, "Alpha Mode");
            if (_alphaModeFoldout)
            {
                EditorGUI.indentLevel++;
                
                EditorGUILayout.HelpBox("Configure how the shader handles transparency:\n\n" +
                    "• Clip: Uses alpha testing (clip), returns alpha = 1\n" +
                    "• Clip With Alpha: Uses alpha testing and returns texture alpha\n" +
                    "• Alpha: Pure alpha blending, no clipping", MessageType.Info);
                
                materialEditor.ShaderProperty(_alphaMode, "Alpha Mode");
                
                int alphaMode = Mathf.RoundToInt(_alphaMode.floatValue);
                
                //if (alphaMode <= 1) // Clip or ClipWithAlpha modes
                {
                    materialEditor.RangeProperty(_cutoff, "Alpha Cutoff (Main Pass)");
                    
                    EditorGUILayout.Space();
                    materialEditor.ShaderProperty(_useSeparateDepthCutoff, "Use Separate Depth Cutoff");
                    
                    bool useSeparateDepthCutoff = _useSeparateDepthCutoff.floatValue > 0.5f;
                    if (useSeparateDepthCutoff)
                    {
                        materialEditor.RangeProperty(_depthCutoff, "Alpha Cutoff (Depth/Shadow Passes)");
                        EditorGUILayout.HelpBox("Using separate cutoff for depth and shadow passes. This allows for better shadow casting while maintaining clean transparency in the main pass.", MessageType.Info);
                    }
                    else
                    {
                        EditorGUILayout.HelpBox("Using the same cutoff for all passes. Main pass cutoff will be used for depth and shadow passes.", MessageType.None);
                    }
                    
                    if (alphaMode == 0) // Clip mode only
                    {
                        EditorGUILayout.Space();
                        materialEditor.ShaderProperty(_smoothDither, "Smooth Dither");
                        
                        if (_smoothDither.floatValue > 0.5f)
                        {
                            materialEditor.RangeProperty(_ditherStrength, "Dither Strength");
                            EditorGUILayout.HelpBox("Smooth Dither reduces aliasing by using temporal dithering instead of hard clipping. Dither Strength controls the intensity of the dithering effect:\n\n" +
                                "• Lower values (0.1-0.5): More conservative dithering, sharper edges\n" +
                                "• Higher values (0.8-2.0): More aggressive dithering, softer transitions", MessageType.None);
                        }
                    }
                }
                
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
        
        private void DrawSystemSettings(MaterialEditor materialEditor)
        {
            _systemFoldout = EditorGUILayout.BeginFoldoutHeaderGroup(_systemFoldout, "System Settings");
            if (_systemFoldout)
            {
                EditorGUI.indentLevel++;
                
                // Cull Mode
                EditorGUILayout.LabelField("Cull Mode", EditorStyles.boldLabel);
                int cullMode = (int)_cull.floatValue;
                string[] cullOptions = {"Off", "Front", "Back"};
                EditorGUI.BeginChangeCheck();
                cullMode = EditorGUILayout.Popup("Cull", cullMode, cullOptions);
                if (EditorGUI.EndChangeCheck())
                {
                    _cull.floatValue = cullMode;
                }
                
                EditorGUILayout.HelpBox("Cull Mode determines which faces are rendered:\n\n" +
                    "• Off: Renders both front and back faces (best for hair)\n" +
                    "• Front: Only renders back faces\n" +
                    "• Back: Only renders front faces", MessageType.Info);
                
                EditorGUI.indentLevel--;
            }
            EditorGUILayout.EndFoldoutHeaderGroup();
        }
    }
}
