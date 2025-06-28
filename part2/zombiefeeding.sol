pragma solidity ^0.4.19; // Pour les versions modernes, préférer ^0.8.0 ou plus

// On importe le contrat ZombieFactory, qui contient la logique de base des zombies
import "./zombiefactory.sol";

// Interface pour interagir avec le contrat externe des CryptoKitties
// Elle permet d'appeler leur fonction getKitty pour récupérer les infos d’un chat
contract KittyInterface {
    // La fonction retourne de nombreuses infos, mais ici seul 'genes' (ADN) nous intéresse
    function getKitty(uint256 _id) external view returns (
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

// Notre nouveau contrat hérite de ZombieFactory
contract ZombieFeeding is ZombieFactory {

    // L’adresse du contrat CryptoKitties était codée en dur ici :
    // address ckAddress = 0x06012c8cf97BEaD5deAe237070F9587f8E7A266d;
    // → Mauvaise pratique, on la supprime pour plus de flexibilité

    // On déclare une variable de type interface pour stocker l’adresse du contrat Kitty
    KittyInterface public kittyContract;

    // Méthode pour définir dynamiquement l’adresse du contrat CryptoKitties
    // En pratique, on devrait restreindre à onlyOwner (non vu encore à ce stade)
    function setKittyContractAddress(address _address) external {
        kittyContract = KittyInterface(_address);
    }

    // Fonction principale pour nourrir un zombie avec l’ADN d’un autre être (chat, humain, etc.)
    function feedAndMultiply(uint _zombieId, uint _targetDna, string _species) public {
        // Vérifie que celui qui appelle la fonction est bien le propriétaire du zombie
        require(msg.sender == zombieToOwner[_zombieId]);

        // Récupère le zombie ciblé depuis le tableau zombies
        Zombie storage myZombie = zombies[_zombieId];

        // On s’assure que l’ADN reste sur 16 chiffres
        _targetDna = _targetDna % dnaModulus;

        // Crée un nouvel ADN basé sur la moyenne des deux
        uint newDna = (myZombie.dna + _targetDna) / 2;

        // Si la cible est un "kitty", on force les 2 derniers chiffres de l’ADN à 99
        // Cela nous permettra de reconnaître un zombie issu d’un chat plus tard
        if (keccak256(_species) == keccak256("kitty")) {
            newDna = newDna - newDna % 100 + 99;
        }

        // Crée le nouveau zombie (nom temporaire : "NoName")
        _createZombie("NoName", newDna);
    }

    // Fonction pour nourrir un zombie avec un CryptoKitty spécifique (via son ID)
    function feedOnKitty(uint _zombieId, uint _kittyId) public {
        uint kittyDna;

        // Appel de la fonction getKitty du contrat CryptoKitties
        // On ne garde que la dernière valeur retournée : l'ADN du chat (genes)
        (,,,,,,,,,kittyDna) = kittyContract.getKitty(_kittyId);

        // On nourrit le zombie avec l’ADN du chat
        feedAndMultiply(_zombieId, kittyDna, "kitty");
    }

}
