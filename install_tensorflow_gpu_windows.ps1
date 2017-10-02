# Install CUDA
$wc = New-Object System.Net.WebClient
$wc.DownloadFile('https://developer.nvidia.com/compute/cuda/8.0/Prod2/network_installers/cuda_8.0.61_win10_network-exe', 'cuda_setup.exe')
$wc.DownloadFile('https://developer.nvidia.com/compute/cuda/8.0/Prod2/patches/2/cuda_8.0.61.2_windows-exe', 'cuda_patch.exe')
.\cuda_setup.exe -s | Out-Null
.\cuda_patch.exe -s | Out-Null

# Install CuDNN
$wc.DownloadFile('https://www.dropbox.com/s/p8vs9uaml0m6tqr/cudnn-8.0-windows10-x64-v6.0.zip?dl=1', 'cudnn.zip')
Add-Type -AssemblyName System.IO.Compression.FileSystem
function Unzip
{
    param([string]$zipfile, [string]$outpath)
    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}
Unzip "cudnn.zip" "cudnn"
cp -r ".\cudnn\cuda\*" "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v8.0\"


# Install Tensorflow
pip install tensorflow-gpu
