$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\$sut"

Describe "RGBColor" {
    Context "正常" {
        It "赤を返す。" {
            $c = [RGBColor]::new(10, 20, 30)
            $c.GetRed() | Should -Be 10
        }
        It "緑を返す。" {
            $c = [RGBColor]::new(10, 20, 30)
            $c.GetGreen() | Should -Be 20
        }
        It "青を返す。" {
            $c = [RGBColor]::new(10, 20, 30)
            $c.GetBlue() | Should -Be 30
        }
        It "すべて0で例外を発生しない。" {
            [RGBColor]::new(0, 0, 0)
        }
        It "すべて255で例外を発生しない。" {
            [RGBColor]::new(255, 255, 255)
        }
    }
    Context "異常" {
        It "色の要素が0未満ならば例外を発生する。" {
            try {
                [RGBColor]::new(-1, -1, -1)
                $true | Should -Be $false
            } catch {
            }
        }
        It "色の要素が256以上ならば例外を発生する。" {
            try {
                [RGBColor]::new(256, 256, 256)
                $true | Should -Be $false
            } catch {
            }
        }
    }
}

Describe "AngleInDegree" {
    Context "正常" {
        It "0度を返す。" {
            $a = [AngleInDegree]::new(0)
            $a.GetAngleInDegree() | Should -Be 0
        }
        It "359度を返す。" {
            $a = [AngleInDegree]::new(359)
            $a.GetAngleInDegree() | Should -Be 359
        }
    }
    Context "異常" {
        It "0未満ならば例外を発生する。" {
            try {
                [AngleInDegree]::new(-0.1)
                $true | Should -Be $false
            } catch {
            }
        }
        It "360度以上ならば例外を発生する。" {
            try {
                [AngleInDegree]::new(360)
                $true | Should -Be $false
            } catch {
            }
        }
    }
}

Describe "HSVSaturation" {
    Context "正常" {
        It "0を返す。" {
            $s = [HSVSaturation]::new(0)
            $s.GetSaturation() | Should -Be 0
        }
        It "1を返す。" {
            $s = [HSVSaturation]::new(1)
            $s.GetSaturation() | Should -Be 1
        }
    }
    Context "異常" {
        It "0未満ならば例外を発生する。" {
            try {
                [HSVSaturation]::new(-0.1)
                $true | Should -Be $false
            } catch {
            }
        }
        It "1を超えるならば例外を発生する。" {
            try {
                [HSVSaturation]::new(1.1)
                $true | Should -Be $false
            } catch {
            }
        }
    }
}

Describe "HSVValue" {
    Context "正常" {
        It "0を返す。" {
            $s = [HSVValue]::new(0)
            $s.GetValue() | Should -Be 0
        }
        It "1を返す。" {
            $s = [HSVValue]::new(1)
            $s.GetValue() | Should -Be 1
        }
    }
    Context "異常" {
        It "0未満ならば例外を発生する。" {
            try {
                [HSVValue]::new(-0.1)
                $true | Should -Be $false
            } catch {
            }
        }
        It "1を超えるならば例外を発生する。" {
            try {
                [HSVValue]::new(1.1)
                $true | Should -Be $false
            } catch {
            }
        }
    }
}

Describe "HSVColor" {
    Context "正常" {
        It "色相を返す。" {
            $Hue = [AngleInDegree]::new(10)
            $Saturation = [HSVSaturation]::new(0.1)
            $Value = [HSVValue]::new(0.2)
            $Color = [HSVColor]::new($Hue, $Saturation, $Value)
            $Hue2 = $Color.GetHue()
            $Hue2.GetAngleInDegree() | Should -Be 10
        }
        It "彩度を返す。" {
            $Hue = [AngleInDegree]::new(10)
            $Saturation = [HSVSaturation]::new(0.1)
            $Value = [HSVValue]::new(0.2)
            $Color = [HSVColor]::new($Hue, $Saturation, $Value)
            $Saturation2 = $Color.GetSaturation()
            $Diff = [Math]::Abs($Saturation2.GetSaturation() - 0.1)
            $Diff | Should -BeLessThan 0.01
        }
        It "明度を返す。" {
            $Hue = [AngleInDegree]::new(10)
            $Saturation = [HSVSaturation]::new(0.1)
            $Value = [HSVValue]::new(0.2)
            $Color = [HSVColor]::new($Hue, $Saturation, $Value)
            $Value2 = $Color.GetValue()
            $Diff = [Math]::Abs($Value2.GetValue() - 0.2)
            $Diff | Should -BeLessThan 0.01
        }
    }
}

Describe "RGBColorToHSVColorConverter" {
    Context "正常" {
        It "色相0度を返す。" {
            $RgbPct = 100, 0, 0
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Hue = $Color2.GetHue()
            $Diff = [Math]::Abs($Hue.GetAngleInDegree() - 0)
            $Diff | Should -BeLessThan 0.1
        }
        It "色相60度を返す。" {
            $RgbPct = 75, 75, 0
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Hue = $Color2.GetHue()
            $Diff = [Math]::Abs($Hue.GetAngleInDegree() - 60)
            $Diff | Should -BeLessThan 0.1

        }
        It "色相120度を返す。" {
            $RgbPct = 0, 50, 0
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Hue = $Color2.GetHue()
            $Diff = [Math]::Abs($Hue.GetAngleInDegree() - 120)
            $Diff | Should -BeLessThan 0.1
        }
        It "色相180度を返す。" {
            $RgbPct = 50, 100, 100
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Hue = $Color2.GetHue()
            $Diff = [Math]::Abs($Hue.GetAngleInDegree() - 180)
            $Diff | Should -BeLessThan 0.1
        }
        It "色相240度を返す。" {
            $RgbPct = 50, 50, 100
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Hue = $Color2.GetHue()
            $Diff = [Math]::Abs($Hue.GetAngleInDegree() - 240)
            $Diff | Should -BeLessThan 0.1
        }
        It "色相300度を返す。" {
            $RgbPct = 75, 25, 75
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Hue = $Color2.GetHue()
            $Diff = [Math]::Abs($Hue.GetAngleInDegree() - 300)
            $Diff | Should -BeLessThan 0.1
        }
        It "彩度を返す。" {
            $RgbPct = 75, 75, 0
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Saturation = $Color2.GetSaturation()
            $Diff = [Math]::Abs($Saturation.GetSaturation() - 1)
            $Diff | Should -BeLessThan 0.01
        }
        It "明度を返す。" {
            $RgbPct = 75, 75, 0
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Value = $Color2.GetValue()
            $Diff = [Math]::Abs($Value.GetValue() - 0.75)
            $Diff | Should -BeLessThan 0.01
        }
        It "RGB(100%,100%,100%)は期待通りのHSVを返す。" {
            $RgbPct = 100, 100, 100
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)

            # 白の色相は0を返す仕様とする。
            $Hue = $Color2.GetHue()
            $AngleInDegree = $Hue.GetAngleInDegree()
            $Diff = [Math]::Abs($AngleInDegree - 0)
            $Diff | Should -BeLessThan 0.1

            $Saturation = $Color2.GetSaturation()
            $Diff = [Math]::Abs($Saturation.GetSaturation() - 0)
            $Diff | Should -BeLessThan 0.01

            $Value = $Color2.GetValue()
            $Diff = [Math]::Abs($Value.GetValue() - 1)
            $Diff | Should -BeLessThan 0.01
        }
        It "RGB(0%,0%,0%)は期待通りのHSVを返す。" {
            $RgbPct = 0, 0, 0
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)

            # 黒の色相は0を返す仕様とする。
            $Hue = $Color2.GetHue()
            $AngleInDegree = $Hue.GetAngleInDegree()
            $Diff = [Math]::Abs($AngleInDegree - 0)
            $Diff | Should -BeLessThan 0.1

            $Saturation = $Color2.GetSaturation()
            $Diff = [Math]::Abs($Saturation.GetSaturation() - 0)
            $Diff | Should -BeLessThan 0.01

            $Value = $Color2.GetValue()
            $Diff = [Math]::Abs($Value.GetValue() - 0)
            $Diff | Should -BeLessThan 0.01
        }
        It "RGB(62.8%,64.3%,14.2%)は期待通りのHSVを返す。" {
            $RgbPct = 62.8, 64.3, 14.2
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)

            $Hue = $Color2.GetHue()
            $AngleInDegree = $Hue.GetAngleInDegree()
            $Diff = [Math]::Abs($AngleInDegree - 61.8)
            $Diff | Should -BeLessThan 0.1

            $Saturation = $Color2.GetSaturation()
            $Diff = [Math]::Abs($Saturation.GetSaturation() - 0.779)
            $Diff | Should -BeLessThan 0.01

            $Value = $Color2.GetValue()
            $Diff = [Math]::Abs($Value.GetValue() - 0.643)
            $Diff | Should -BeLessThan 0.01
        }
    }
}

Describe "HSVColorToRGBColorConverter" {
    Context "正常" {
        It "色を返す。" {
            $RgbPct = 100, 0, 0
            $Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
            $Red, $Green, $Blue = $Rgb
            $Color1 = [RGBColor]::new($Red, $Green, $Blue)
            $Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)
            $Color3 = [HSVColorToRGBColorConverter]::Convert($Color2)
            $Color3.GetRed() | Should -Be 255
            $Color3.GetGreen() | Should -Be 0
            $Color3.GetBlue() | Should -Be 0
        }
    }
}
