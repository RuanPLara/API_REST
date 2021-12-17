object WMMain: TWMMain
  OldCreateOrder = False
  OnCreate = WebModuleCreate
  Actions = <
    item
      Default = True
      Name = 'Index'
      PathInfo = '/'
      OnAction = WMMainIndexAction
    end
    item
      MethodType = mtGet
      Name = 'RecuperaBinVideo'
      PathInfo = '/api/server/*/videos/*/bin'
      OnAction = WMMainRecuperaBinVideoAction
    end
    item
      Name = 'VideosOperation'
      PathInfo = '/api/server/*/videos/*'
      OnAction = WMMainVideosOperationAction
    end
    item
      Name = 'ServerVideos'
      PathInfo = '/api/server/*/videos'
      OnAction = WMMainServerVideosAction
    end
    item
      MethodType = mtGet
      Name = 'StatusServer'
      PathInfo = '/api/server/available/*'
      OnAction = WMMainStatusServerAction
    end
    item
      Name = 'Servers'
      PathInfo = '/api/server/*'
      OnAction = WMMainServersAction
    end
    item
      Name = 'Server'
      PathInfo = '/api/server'
      OnAction = WMMainServerAction
    end>
  Height = 403
  Width = 592
  object CDServer: TClientDataSet
    PersistDataPacket.Data = {
      6E0000009619E0BD0100000018000000040000000000030000006E0002494401
      00490000000100055749445448020002002800044E414D450100490000000100
      0557494454480200020032000249500100490000000100055749445448020002
      000F0004504F525404000100000000000000}
    Active = True
    Aggregates = <>
    Params = <>
    AfterPost = CDServerAfterPost
    AfterDelete = CDServerAfterPost
    Left = 48
    Top = 32
    object CDServerID: TStringField
      FieldName = 'ID'
      Size = 40
    end
    object CDServerNAME: TStringField
      FieldName = 'NAME'
      Size = 50
    end
    object CDServerIP: TStringField
      FieldName = 'IP'
      Size = 15
    end
    object CDServerPORT: TIntegerField
      FieldName = 'PORT'
    end
  end
  object CdArquivos: TClientDataSet
    PersistDataPacket.Data = {
      740000009619E0BD010000001800000004000000000003000000740002494401
      00490000000100055749445448020002002800044E414D450100490000000100
      0557494454480200020032000453495A45040001000000000008534552564552
      494401004900000001000557494454480200020028000000}
    Active = True
    Aggregates = <>
    Params = <>
    AfterPost = CdArquivosAfterPost
    AfterDelete = CdArquivosAfterPost
    Left = 120
    Top = 32
    object CdArquivosID: TStringField
      FieldName = 'ID'
      Size = 40
    end
    object CdArquivosNAME: TStringField
      FieldName = 'NAME'
      Size = 50
    end
    object CdArquivosSIZE: TIntegerField
      FieldName = 'SIZE'
    end
    object CdArquivosSERVERID: TStringField
      FieldName = 'SERVERID'
      Size = 40
    end
  end
end
