Create a python3 script `apply_deref.py` in this directory. This script will:
- Read and edit `zstdgpu_shaders.h` in-place.
- Replace occurences of `UAV[COORD_EXPR]` with `DEREF(UAV, (COORD_EXPR))`. Except for `UAV` and `COORD_EXPR`, that is to be taken literally. What constitutes a UAV depends on earlier context in `zstdgpu_shaders.h`.

A `UAV` string contains alphanumeric characters, `.` and `_`. A string is a `UAV` if it starts with `srt.inout`, or it is the `Name` in the the _last_ `ZSTDGPU_*_BUFFER*(T) Name`. For example, if `ZSTDGPU_RW_BUFFER(uint32_t) dispatchArgs` is seen, then `dispatchArgs` is considered a UAV until e.g. `ZSTDGPU_RO_BUFFER(uint32_t) dispatchArgs` is seen.

When capturing `COORD_EXPR`, ensure balanced `[]` if the coord expression itself contains brackets.

Examples:
- `srt.inoutFrameStatus[threadId]` becomes `DEREF(srt.inoutFrameStatus, (threadId))`.
- `dispatchArgs[baseIdx + 4]` becomes `DEREF(dispatchArgs, (baseIdx + 4))`.
- `kzstdgpuFseProbsDefault[srcStart + i]` is unchanged.
