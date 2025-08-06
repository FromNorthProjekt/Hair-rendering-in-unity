using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;
using UnityEngine.Rendering.RendererUtils;
using System.Collections.Generic;
using System.Linq;

// This feature now finds and executes a specific shader pass ("Custom_TransparentDepthPrepass")
// for any objects that have it, rather than overriding all transparents.
public class TransparentDepthPrePassFeature : ScriptableRendererFeature
{
    // We no longer need any settings for this feature.
    private TransparentDepthPrePass m_ScriptablePass;

    class TransparentDepthPrePass : ScriptableRenderPass
    {
        // THE NEW SHADER TAG WE WILL LOOK FOR
        private static readonly ShaderTagId k_ShaderTagId = new ShaderTagId("Custom_TransparentDepthPrepass");

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            UniversalRenderingData renderingData = frameData.Get<UniversalRenderingData>();
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();
            UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();

            using (var builder = renderGraph.AddRasterRenderPass<PassData>("Opt-In Transparent Depth Pre-Pass", out var passData))
            {
                builder.AllowPassCulling(false);
                builder.SetRenderAttachmentDepth(resourceData.activeDepthTexture, AccessFlags.Write);

                // Create a list of renderers, but this time, filter by our custom shader tag.
                // We no longer override the material, because the shader itself contains the correct pass.
                var rendererListDesc = new RendererListDesc(k_ShaderTagId, renderingData.cullResults, cameraData.camera)
                {
                    // We still only look in the transparent queue.
                    renderQueueRange = RenderQueueRange.transparent,
                    sortingCriteria = SortingCriteria.CommonTransparent
                    // NOTE: overrideMaterial is no longer set!
                };

                passData.rendererList = renderGraph.CreateRendererList(rendererListDesc);
                builder.UseRendererList(passData.rendererList);

                builder.SetRenderFunc((PassData data, RasterGraphContext context) =>
                {
                    context.cmd.DrawRendererList(data.rendererList);
                });
            }
        }
        
        private class PassData
        {
            public RendererListHandle rendererList;
        }
    }

    public override void Create()
    {
        m_ScriptablePass = new TransparentDepthPrePass();
        m_ScriptablePass.renderPassEvent = RenderPassEvent.BeforeRenderingTransparents;
    }
    
    // No need for Dispose, as we are no longer creating a material internally.

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_ScriptablePass);
    }
}