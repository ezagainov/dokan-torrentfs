object MainForm: TMainForm
  Left = 0
  Top = 0
  Caption = 'MainForm'
  ClientHeight = 325
  ClientWidth = 886
  Color = clBtnFace
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object lvMountController: TListView
    AlignWithMargins = True
    Left = 3
    Top = 26
    Width = 880
    Height = 150
    Align = alTop
    BorderStyle = bsNone
    Columns = <
      item
        Caption = 'Torrent file'
        Width = 400
      end
      item
        Caption = 'Mount point'
        Width = 70
      end
      item
        Caption = 'Suspended'
      end>
    Ctl3D = True
    DoubleBuffered = True
    FlatScrollBars = True
    GridLines = True
    ReadOnly = True
    RowSelect = True
    ParentDoubleBuffered = False
    TabOrder = 0
    ViewStyle = vsReport
    OnInsert = lvMountControllerInsert
    ExplicitLeft = 8
    ExplicitTop = 8
  end
  object ActionToolBar1: TActionToolBar
    Left = 0
    Top = 0
    Width = 886
    Height = 23
    ActionManager = amActions
    Caption = 'ActionToolBar1'
    Color = clMenuBar
    ColorMap.DisabledFontColor = 7171437
    ColorMap.HighlightColor = clWhite
    ColorMap.BtnSelectedFont = clBlack
    ColorMap.UnusedColor = clWhite
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clBlack
    Font.Height = -11
    Font.Name = 'Tahoma'
    Font.Style = []
    ParentFont = False
    Spacing = 0
  end
  object amActions: TActionManager
    ActionBars = <
      item
        Items = <
          item
            Action = actMountAll
            Caption = '&actMountAll'
          end
          item
            Action = actUnmountAll
            Caption = 'a&ctUnmountAll'
          end
          item
            Action = actClear
            Caption = 'ac&tClear'
          end
          item
            Action = actAddTest
            Caption = 'actA&ddTest'
          end>
        ActionBar = ActionToolBar1
      end>
    Left = 808
    Top = 72
    StyleName = 'Platform Default'
    object actMountAll: TAction
      Caption = 'actMountAll'
      OnExecute = actMountAllExecute
    end
    object actUnmountAll: TAction
      Caption = 'actUnmountAll'
      OnExecute = actUnmountAllExecute
    end
    object actClear: TAction
      Caption = 'actClear'
      OnExecute = actClearExecute
    end
    object actAddTest: TAction
      Caption = 'actAddTest'
    end
  end
end
