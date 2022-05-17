// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0 <0.9.0;

import "./ZombieFactory.sol";

interface KittyInterface {
  function getKitty(uint256 _id)
    external
    view
    returns (
      bool isGestating,
      bool isReady,
      uint256 cooldownIndex,
      uint256 nextActionAt,
      uint256 siringWithId,
      uint256 birthTime,
      uint256 matronId,
      uint256 sireId,
      uint256 generation,
      uint256 genes
    );
}

contract ZombieFeeding is ZombieFactory {
  KittyInterface public kittyInterface;

  /**
   * @dev Changes and sets the address of the CryptoKitties smart contract
   * @param _address The actual address of the deployed CryptoKitties smart contract
   */
  function setKittyContractAddress(address _address) external onlyOwner {
    kittyInterface = KittyInterface(_address);
  }

  /**
   * @dev Sets the readytime for the zombie before he can attack again
   * @param _zombie A reference to the zombie
   */
  function _triggerCooldown(Zombie storage _zombie) internal {
    _zombie.readyTime = uint32(block.timestamp + cooldownTime);
  }

  /**
   * @dev Checks if the zombie is ready to attack
   * @param _zombie A reference to the zombie
   */
  function _isReady(Zombie storage _zombie) internal view returns (bool) {
    return _zombie.readyTime <= block.timestamp;
  }

  /**
   * @dev Creates a new zombie from the zombieId and the DNA of a target
   * @param _zombieId The ID of the zombie that feeds on the target.
   * @param _targetDna The ID of the target that is being fed on.
   */
  function feedAndMultiply(
    uint256 _zombieId,
    uint256 _targetDna,
    string memory _species
  ) public {
    require(
      msg.sender == zombieToOwner[_zombieId],
      "You don't own this zombie"
    );

    Zombie storage myZombie = zombies[_zombieId];
    _targetDna = _targetDna % dnaModulus;
    uint256 newDna = (myZombie.dna + _targetDna) / 2;

    // uint256 newDna = zombies[_zombieId].dna % dnaModulus;

    if (keccak256(abi.encode(_species)) == keccak256(abi.encode("kitty"))) {
      newDna = newDna - (newDna % 100) + 99;
    }

    _createZombie("No name", newDna);
  }

  /**
   * @dev A function that allows a zombie to feed on a kitty, accessing its DNA.
   * @param _zombieId The ID of the zombie that feeds on the kitty.
   * @param _kittyId The ID of the kitty that is being fed on.
   */
  function feedOnKitty(uint256 _zombieId, uint256 _kittyId) public {
    uint256 kittyDna;

    (, , , , , , , , , kittyDna) = kittyInterface.getKitty(_kittyId);

    feedAndMultiply(_zombieId, kittyDna, "kitty");
  }
}
