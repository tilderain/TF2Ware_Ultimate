@echo off

for %%f in (
    ware_mirror_ps2x.hlsl
    ware_nostalgia_ps2x.hlsl
) do (
    call ShaderCompile.exe -ver 20b -shaderpath "%cd%" %%f
)

echo Done

pause