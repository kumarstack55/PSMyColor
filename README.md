# PSMyColor

色を扱うライブラリです。

## 主な機能

* RGB to HSV 変換
* HSV to RGB 変換

## 要件

PowerShell 5.1

## インストール

```powershell
git clone https://github.com/kumarstack55/PSMyColor.git
```

## 使い方

```powershell
# RGB(62.8%, 64.3%, 14.2%) を得る。
$RgbPct = 62.8, 64.3, 14.2
$Rgb = $RgbPct | ForEach-Object { ($_ / 100) * 255 }
$Red, $Green, $Blue = $Rgb
$Color1 = [RGBColor]::new($Red, $Green, $Blue)

# RGB を HSV に変換する。
$Color2 = [RGBColorToHSVColorConverter]::Convert($Color1)

$Hue = $Color2.GetHue()
$Hue.GetAngleInDegree()
    # --> 61.8
$Saturation = $Color2.GetSaturation()
$Saturation.GetSaturation()
    # --> 0.779
$Value = $Color2.GetValue()
$Value.GetValue()
    # --> 0.643
```

詳細はテストコードを参照してください。

## ライセンス

MIT
