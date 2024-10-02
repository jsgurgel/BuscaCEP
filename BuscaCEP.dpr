program BuscaCEP;

{$APPTYPE CONSOLE}

uses
System.SysUtils, Horse, Horse.CORS, System.JSON, REST.Client, REST.Types;



procedure ConsultaCep(Req: THorseRequest; Res: THorseResponse; Next: TNextProc);
var
  Cep: string;
  RestClient: TRESTClient;
  RestRequest: TRESTRequest;
  RestResponse: TRESTResponse;
  JSONResponse: TJSONObject;
begin
  Cep := Req.Params.Items['cep'];

  if Cep = '' then
  begin
    Res.Status(400).Send('O CEP é obrigatório');
    Exit;
  end;

  RestClient := TRESTClient.Create('https://viacep.com.br/ws/' + Cep + '/json/');
  RestRequest := TRESTRequest.Create(nil);
  RestResponse := TRESTResponse.Create(nil);

  try
    RestRequest.Client := RestClient;
    RestRequest.Response := RestResponse;
    RestRequest.Method := TRESTRequestMethod.rmGET;
    RestRequest.Execute;

    if RestResponse.StatusCode = 200 then
    begin
      JSONResponse := TJSONObject.ParseJSONValue(RestResponse.Content) as TJSONObject;
      Res.Send(RestResponse.Content);
    end
    else
      Res.Status(RestResponse.StatusCode).Send('Erro ao consultar o CEP');
  finally
    RestClient.Free;
    RestRequest.Free;
    RestResponse.Free;
  end;
end;

Var
  App : THorse;

begin
  ReportMemoryLeaksOnShutdown := True;
  App := THorse.Create();
  App.Use(CORS);

    // Definição da rota para consulta de CEP
  app.Get('/cep/:cep',  ConsultaCep);


  App.Listen(80,
    procedure
    begin
      Writeln('Server is runing on port ' + IntToStr(THorse.Port));
      Readln;
    end);
end.