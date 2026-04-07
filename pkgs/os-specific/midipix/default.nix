{
  makeScopeWithSplicing',
  generateSplicesForMkScope,
}:

let
  otherSplices = generateSplicesForMkScope "midipix";
in
makeScopeWithSplicing' {
  inherit otherSplices;
  f =
    self:
    let
      callPackage = self.callPackage;
    in
    {
    };
}
