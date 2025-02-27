unit UTClientRequestUnit;

interface

type
  TUTClientRequest = (crLoadCatalog = 1);

  TUTClientRequestHelper = record helper for TUTClientRequest
  public
    function ToInteger: Integer;
  end;

implementation

function TUTClientRequestHelper.ToInteger: Integer;
begin
  Result := Integer(Self);
end;

end.
