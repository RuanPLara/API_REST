program ServerRest;
{$APPTYPE GUI}

uses
  Vcl.Forms,
  Web.WebReq,
  IdHTTPWebBrokerBridge,
  uFoMain in 'uFoMain.pas' {FormMain},
  uWebModuleMain in 'uWebModuleMain.pas' {WMMain: TWebModule},
  UnControl in 'UnControl.pas';

{$R *.res}

begin
  if WebRequestHandler <> nil then
    WebRequestHandler.WebModuleClass := WebModuleClass;
  Application.Initialize;
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
