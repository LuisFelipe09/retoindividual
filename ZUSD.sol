// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@chainlink/contracts/src/v0.8/KeeperCompatible.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ZUSD is KeeperCompatibleInterface {
    
    uint public immutable interval;
    uint public lastTimeStamp; //intevalo de tiempo en segundos
    IERC20 private _tokenUSDZ;
    IERC20 private _tokenUSDC;
    address private _consumer;
    uint256 private _amount;
    address private _ownerAmount;

    constructor(uint _interval, address addressTokenUSDZ, address addressTokenUSDC) {
       interval = _interval;
       lastTimeStamp = block.timestamp;
       _tokenUSDZ = IERC20(addressTokenUSDZ);
       _tokenUSDC = IERC20(addressTokenUSDC);
       _ownerAmount = address(0);
    }


    function getAmount() public view returns (uint256 amount){
        return _amount;
    }


    function changeTokens(uint256 amount) public returns (bool estado) {
      require(_ownerAmount == msg.sender || _ownerAmount == address(0), "Ya se utilizo el contrato");
      if(_ownerAmount == address(0)) _ownerAmount = msg.sender;
      
      try _tokenUSDZ.transferFrom(msg.sender, address(this), amount) returns (bool _estado) {
        _consumer = msg.sender;
        _amount = amount;
        estado = _estado;
      } catch {
        estado = false;
      }

      return estado;
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory /* performData */) {
        upkeepNeeded = ((block.timestamp - lastTimeStamp) > interval);        
        // We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.
    }

    function performUpkeep(bytes calldata /* performData */) external override {
        //We highly recommend revalidating the upkeep in the performUpkeep function
        if ((block.timestamp - lastTimeStamp) > interval ) {
            lastTimeStamp = block.timestamp;
            //logic
            _tokenUSDC.transfer(_consumer, _amount);

        }
        // We don't use the performData in this example. The performData is generated by the Keeper's call to your checkUpkeep function
    }
}
