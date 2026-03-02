/**
 * ZstdGpuExecuteSequences.hlsl
 *
 * A compute shader that executes sequences.
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

#include "../zstdgpu_srt_decl_bind.h"
ZSTDGPU_EXECUTE_SEQUENCES_SRT()
#include "../zstdgpu_srt_decl_undef.h"

[RootSignature("DescriptorTable(SRV(t0, numDescriptors=13), UAV(u0, numDescriptors=2))")]
[numthreads(MAX_COPY_SIZE, 1, 1)]
#if SINGLE_WAVE
[wavesize(MAX_COPY_SIZE)]
#endif
void main(uint groupId : SV_GroupId, uint i : SV_GroupThreadId)
{
    zstdgpu_ExecuteSequences_SRT srt;

    #include "../zstdgpu_srt_decl_copy.h"
    ZSTDGPU_EXECUTE_SEQUENCES_SRT()
    #include "../zstdgpu_srt_decl_undef.h"

#if SINGLE_WAVE
    const uint32_t frameIdx = groupId;
#else
    uint32_t frameIdx = 0;
    if (WaveIsFirstLane())
    {
        InterlockedAdd(srt.inoutCounters_RW_Counters[0].Frames_ExecuteSequences, 1, frameIdx);
    }
    frameIdx = WaveReadLaneFirst(frameIdx);
#endif

    zstdgpu_ShaderEntry_ExecuteSequences(srt, frameIdx);
}
