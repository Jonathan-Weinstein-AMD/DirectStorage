/**
 * ZstdGpuParseCompressedBlocks.hlsl
 *
 * A compute shader that parses compressed Zstd blocks, extracts locations of
 * other sub-blocks such as literals, Huffman Weights and FSE tables, and
 * executes FSE table index propagation via "Decoupled Lookback",
 * so each block refer its FSE tables directly.
 * The shader maps one compressed block to a single thread.
 *
 * Copyright (c) Microsoft. All rights reserved.
 * This code is licensed under the MIT License (MIT).
 * THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
 * ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
 * IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
 * PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
 *
 * Advanced Technology Group (ATG)
 * Author(s):   Pavel Martishevsky (pamartis@microsoft.com)
 */

#include "../zstdgpu_shaders.h"

#include "../srt_headers/ZstdGpuSrt_ParseCompressedBlocks.h"

#ifdef __XBOX_SCARLETT
#define __XBOX_ENABLE_WAVE32 1
#endif

[RootSignature(ZSTDGPU_SRT_RS_ParseCompressedBlocks)]
[numthreads(kzstdgpu_TgSizeX_ParseCompressedBlocks, 1, 1)]
void main(uint2 groupId : SV_GroupId, uint threadId : SV_GroupThreadId)
{
    zstdgpu_ParseCompressedBlocks_SRT srt;
    zstdgpu_Srt_Fill(srt);
    // TODO: make the srtgen tool put this at the end of zstdgpu_Srt_Fill:
    if (int(srt.workItemCount) < 0)
    {
        const uint32_t slot = ~srt.workItemCount; // decode slot
        const uint32_t baseIdx = slot * kzstdgpu_DispatchSlot_StrideInUInt32;
        srt.workItemCount = ZstdInDispatchArgs[baseIdx + 1]; // skip tgOffset to load the actual workItemCount
    }

    const uint32_t i = zstdgpu_ConvertTo32BitGroupId(groupId, srt.tgOffset) * kzstdgpu_TgSizeX_ParseCompressedBlocks + threadId;

    zstdgpu_Srt_FillInline(srt, srt.workItemCount);

    zstdgpu_ShaderEntry_ParseCompressedBlocks(srt, i);
}
