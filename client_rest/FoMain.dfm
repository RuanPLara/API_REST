object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Form1'
  ClientHeight = 594
  ClientWidth = 1042
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object BtCarregaArquivo: TButton
    Left = 0
    Top = 105
    Width = 1042
    Height = 25
    Align = alTop
    Caption = 'Carrega Arquivo e convert to base 64'
    TabOrder = 0
    OnClick = BtCarregaArquivoClick
  end
  object MmBase64: TMemo
    Left = 0
    Top = 180
    Width = 1042
    Height = 414
    Align = alClient
    Lines.Strings = (
      'MmBase64')
    ScrollBars = ssBoth
    TabOrder = 1
    WordWrap = False
  end
  object BtEnviaArquivo: TButton
    Left = 0
    Top = 155
    Width = 1042
    Height = 25
    Align = alTop
    Caption = 'Envia para api rest'
    TabOrder = 2
    OnClick = BtEnviaArquivoClick
    ExplicitTop = 130
  end
  object GroupBox1: TGroupBox
    Left = 0
    Top = 0
    Width = 1042
    Height = 105
    Align = alTop
    Caption = 'Dados de envio'
    TabOrder = 3
    object Label1: TLabel
      Left = 3
      Top = 13
      Width = 59
      Height = 13
      Caption = 'Id do server'
    end
    object Label2: TLabel
      Left = 3
      Top = 59
      Width = 53
      Height = 13
      Caption = 'End da API'
    end
    object EdServer: TEdit
      Left = 3
      Top = 32
      Width = 390
      Height = 21
      TabOrder = 0
      Text = '90C596C8-C92D-4EFD-8CB8-085FF3FEDE89'
    end
    object EdApi: TEdit
      Left = 3
      Top = 78
      Width = 390
      Height = 21
      TabOrder = 1
      Text = 'http://localhost:8080'
    end
  end
  object Button1: TButton
    Left = 0
    Top = 130
    Width = 1042
    Height = 25
    Align = alTop
    Caption = 'Convert base64 to file'
    TabOrder = 4
    OnClick = Button1Click
    ExplicitTop = 113
  end
  object OpenDialog1: TOpenDialog
    Left = 448
    Top = 152
  end
  object IdHTTP1: TIdHTTP
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = -1
    Request.ContentRangeStart = -1
    Request.ContentRangeInstanceLength = -1
    Request.Accept = 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    Request.Ranges.Units = 'bytes'
    Request.Ranges = <>
    HTTPOptions = [hoForceEncodeParams]
    Left = 512
    Top = 304
  end
end
