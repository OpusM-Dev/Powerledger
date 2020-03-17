pragma solidity ^0.5.0;

library Math {
  function max256(uint256 _a, uint256 _b) internal pure returns (uint256) {
    return _a >= _b ? _a : _b;
  }
}
