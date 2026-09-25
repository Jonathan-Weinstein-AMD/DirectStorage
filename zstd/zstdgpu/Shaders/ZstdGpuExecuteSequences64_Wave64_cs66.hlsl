/**
 * ZstdGpuExecuteSequences64_Wave64_cs66.hlsl
 *
 * A specialisation for the compute shader that executes sequences.
 *
 * Copyright (c) Microsoft. All rights reserved.
 * This code is licensed under the MIT License (MIT).
 * THIS CODE IS PROVIDED *AS IS* WITHOUT WARRANTY OF
 * ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING ANY
 * IMPLIED WARRANTIES OF FITNESS FOR A PARTICULAR
 * PURPOSE, MERCHANTABILITY, OR NON-INFRINGEMENT.
 */

#define MAX_COPY_SIZE 64
#define FORCED_WAVE_SIZE MAX_COPY_SIZE
#include "ZstdGpuExecuteSequences.hlsli"
