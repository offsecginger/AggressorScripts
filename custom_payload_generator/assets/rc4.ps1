function BinToHex {
	param(
	[Parameter(
		Position=0, 
		Mandatory=$true, 
		ValueFromPipeline=$true)
	]
	[Byte[]]$Bin)
	# assume pipeline input if we don't have an array (surely there must be a better way)
	if ($bin.Length -eq 1) {$bin = @($input)}
	$return = -join ($Bin |  foreach { "{0:X2}" -f $_ })
	Write-Output $return
}
function HexToBin {
	param(
	[Parameter(
		Position=0, 
		Mandatory=$true, 
		ValueFromPipeline=$true)
	]   
	[string]$s)
	$return = @()
	
	for ($i = 0; $i -lt $s.Length ; $i += 2)
	{
		$return += [Byte]::Parse($s.Substring($i, 2), [System.Globalization.NumberStyles]::HexNumber)
	}
	
	Write-Output $return
}
function rc4 {
	param(
		[Byte[]]$data,
		[Byte[]]$key
	)
	[Byte[]]$buffer = New-Object Byte[] $data.Length
	$data.CopyTo($buffer, 0)
	
	[Byte[]]$s = New-Object Byte[] 256;
	[Byte[]]$k = New-Object Byte[] 256;
 
	for ($i = 0; $i -lt 256; $i++)
	{
		$s[$i] = [Byte]$i;
		$k[$i] = $key[$i % $key.Length];
	}
 
	$j = 0;
	for ($i = 0; $i -lt 256; $i++)
	{
		$j = ($j + $s[$i] + $k[$i]) % 256;
		$temp = $s[$i];
		$s[$i] = $s[$j];
		$s[$j] = $temp;
	}
 
	$i = $j = 0;
	for ($x = 0; $x -lt $buffer.Length; $x++)
	{
		$i = ($i + 1) % 256;
		$j = ($j + $s[$i]) % 256;
		$temp = $s[$i];
		$s[$i] = $s[$j];
		$s[$j] = $temp;
		[int]$t = ($s[$i] + $s[$j]) % 256;
		$buffer[$x] = $buffer[$x] -bxor $s[$t];
	}
 
	return $buffer
}

$enc = [System.Text.Encoding]::ASCII
[Byte[]]$data = $enc.GetBytes("Hello World!")
[Byte[]]$key = $enc.GetBytes("SECRET")
$EncryptedBytes = rc4 $data $key
$EncryptedString = BinToHex $EncryptedBytes
Write-Output $EncryptedString
#[Byte[]]$data = HexToBin $EncryptedString
[Byte[]]$data = HexToBin "5086ec62f337"
$DecryptedBytes = rc4 $data $key
$DecryptedString = $enc.GetString($DecryptedBytes)
Write-Output $DecryptedString