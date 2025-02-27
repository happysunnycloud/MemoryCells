unit UTServerReplyUnit;

interface

type
  TUTServerReply = (srLoadCatalog = 1);

  TUTServerReplyHelper = record helper for TUTServerReply
  public
    function ToInteger: Integer;
  end;

implementation

function TUTServerReplyHelper.ToInteger: Integer;
begin
  Result := Integer(Self);
end;

end.
