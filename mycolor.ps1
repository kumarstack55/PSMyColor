class IllegalArgumentException : Exception {
    IllegalArgumentException([String]$Message) : base([String]$Message) {}
}

class InternalErrorException : Exception {
    InternalErrorException([String]$Message) : base([String]$Message) {}
}

# RGB色空間の色
class RGBColor {
    hidden [int32]$Red
    hidden [int32]$Green
    hidden [int32]$Blue
    [int32]GetMaxPrimaryColorDepth() { return [Math]::Pow(2, 8) - 1 }
    hidden ThrowExceptionIfPrimaryColorIsOutOfRange([int32]$PrimaryColor, [string]$ColorName) {
        if (($PrimaryColor -lt 0) -or ($this.GetMaxPrimaryColorDepth() -lt $PrimaryColor)) {
            $Message = "色 {0} が範囲 0-{2} の外です。: {1}" -f $ColorName, $PrimaryColor, $this.GetMaxPrimaryColorDepth()
            throw [IllegalArgumentException]$Message
        }
    }
    RGBColor([int32]$Red, [int32]$Green, [int32]$Blue) {
        $this.ThrowExceptionIfPrimaryColorIsOutOfRange($Red, '赤')
        $this.ThrowExceptionIfPrimaryColorIsOutOfRange($Green, '緑')
        $this.ThrowExceptionIfPrimaryColorIsOutOfRange($Blue, '青')
        $this.Red, $this.Green, $this.Blue = $Red, $Green, $Blue
    }
    static [RGBColor]FromRGB([int32]$Rgb) {
        return [RGBColor]::new(($Rgb % 256), (($Rgb -shr 8) % 256), (($Rgb -shr 16) % 256))
    }
    [int32]GetRed() { return $this.Red }
    [int32]GetGreen() { return $this.Green }
    [int32]GetBlue() { return $this.Blue }
    [int32]GetRGB() {
        return ((($this.Blue -shl 8) + $this.Green) -shl 8) + $this.Red
    }
}

# 角度
class AngleInDegree {
    hidden [float]$AngleInDegree
    AngleInDegree([float]$AngleInDegree) {
        if (($AngleInDegree -lt 0) -or (360 -le $AngleInDegree)) {
            $Message = '角度が範囲 0 以上 360 未満の外です。: {0}' -f $AngleInDegree
            throw [IllegalArgumentException]$Message
        }
        $this.AngleInDegree = $AngleInDegree
    }
    [float]GetAngleInDegree() { return $this.AngleInDegree }
}

# HSV色空間の彩度
class HSVSaturation {
    hidden [float]$Saturation
    HSVSaturation([float]$Saturation) {
        if (($Saturation -lt 0) -or (1 -lt $Saturation)) {
            $Message = '彩度が範囲 0-1 の外です。: {0}' -f $Saturation
            throw [IllegalArgumentException]$Message
        }
        $this.Saturation = $Saturation
    }
    [float]GetSaturation() { return $this.Saturation }
}

# HSV色空間の明度
class HSVValue {
    hidden [float]$Value
    HSVValue([float]$Value) {
        if (($Value -lt 0) -or (1 -lt $Value)) {
            $Message = '明度が範囲 0-1 の外です。: {0}' -f $Value
            throw [IllegalArgumentException]$Message
        }
        $this.Value = $Value
    }
    [float]GetValue() { return $this.Value }
}

# HSV色空間の色
class HSVColor {
    hidden [AngleInDegree]$Hue  # 色相
    hidden [HSVSaturation]$Saturation  # 彩度
    hidden [HSVValue]$Value  # 明度
    HSVColor([AngleInDegree]$Hue, [HSVSaturation]$Saturation, [HSVValue]$Value) {
        $this.Hue = $Hue
        $this.Saturation = $Saturation
        $this.Value = $Value
    }
    [AngleInDegree]GetHue() { return $this.Hue }
    [HSVSaturation]GetSaturation() { return $this.Saturation }
    [HSVValue]GetValue() { return $this.Value }
}

# RGB色空間からHSV色空間への変換器
class RGBColorToHSVColorConverter {
    static [HSVColor]Convert([RGBColor]$Rgb) {
        # RGB を HSV に変換します。
        # atan() などを使用せず、近似的に計算します。

        # RGB を 0.0 - 1.0 の範囲に変換する。
        [float]$Red = $Rgb.GetRed() / $Rgb.GetMaxPrimaryColorDepth()
        [float]$Green = $Rgb.GetGreen() / $Rgb.GetMaxPrimaryColorDepth()
        [float]$Blue = $Rgb.GetBlue() / $Rgb.GetMaxPrimaryColorDepth()
        [float[]]$PrimaryColors = $Red, $Green, $Blue

        # RGBの最大値、最小値を得る。
        $RgbMax = [System.Linq.Enumerable]::Max($PrimaryColors)
        $RgbMin = [System.Linq.Enumerable]::Min($PrimaryColors)

        # Hue を計算する。
        $HueValue = 0
        if ($RgbMax -eq $Red) {
            if ($RgbMax -ne $RgbMin) {
                $HueValue = 60 * ($Green - $Blue) / ($RgbMax - $RgbMin)
                if ($HueValue -lt 0) {
                    $HueValue += 360
                }
            }
        } elseif ($RgbMax -eq $Green) {
            if ($RgbMax -ne $RgbMin) {
                $HueValue = 60 * ($Blue - $Red) / ($RgbMax - $RgbMin) + 120
            }
        } elseif ($RgbMax -eq $Blue) {
            if ($RgbMax -ne $RgbMin) {
                $HueValue = 60 * ($Red - $Green) / ($RgbMax - $RgbMin) + 240
            }
        } else {
            throw [InternalErrorException]
        }
        $local:Hue = [AngleInDegree]::new($HueValue)

        # 彩度を計算する。
        $SaturationValue = 0
        if ($RgbMax -ne 0) {
            $SaturationValue = ($RgbMax - $RgbMin) / $RgbMax
        }
        $local:Saturation = [HSVSaturation]::new($SaturationValue)

        # 明度を計算する。
        $local:Value = [HSVValue]::new($RgbMax)

        return [HSVColor]::new($local:Hue, $local:Saturation, $local:Value)
    }
}

# HSV色空間からRGB色空間への変換器
class HSVColorToRGBColorConverter {
    static [RGBColor]Convert([HSVColor]$Color) {
        $v = $Color.Value.GetValue()
        $s = $Color.Saturation.GetSaturation()
        $c = $v * $s

        $h = $Color.Hue.GetAngleInDegree() / 60
        $x = $c * (1 - [Math]::Abs($h % 2 - 1))
        if ($h -lt 1) {
            $r1, $g1, $b1 = $c, $x, 0
        } elseif ($h -lt 2) {
            $r1, $g1, $b1 = $x, $c, 0
        } elseif ($h -lt 3) {
            $r1, $g1, $b1 = 0, $c, $x
        } elseif ($h -lt 4) {
            $r1, $g1, $b1 = 0, $x, $c
        } elseif ($h -lt 5) {
            $r1, $g1, $b1 = $x, 0, $c
        } elseif ($h -lt 6) {
            $r1, $g1, $b1 = $c, 0, $x
        } else {
            throw [InternalErrorException]
        }

        $m = $v - $c
        $r2, $g2, $b2 = ($r1 + $m), ($g1 + $m), ($b1 + $m)

        return [RGBColor]::new($r2 * 255, $g2 * 255, $b2 * 255)
    }
}
