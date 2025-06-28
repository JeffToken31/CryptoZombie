pragma solidity ^0.4.19; // Pour les versions récentes, utiliser ^0.8.0 ou supérieur

contract ZombieFactory {
    // Event pour indiquer au front la création du zombie
    // Depuis Solidity 0.4.21, il faut utiliser 'emit' pour déclencher un événement
    event NewZombie(uint zombieId, string name, uint dna);

    // Pour maintenir la taille du dna à max 16 chiffres
    uint dnaDigits = 16;
    // Calcul du modulo pour limiter l'ADN à 16 chiffres
    uint dnaModulus = 10 ** dnaDigits;

    // Structure de l'objet Zombie à créer
    struct Zombie {
        string name;
        uint dna;
    }

    // Pour stocker les objets créés
    Zombie[] public zombies;
    
    // Fonction interne pour créer un zombie
    // En version récente, penser à utiliser 'string memory _name'
    function _createZombie(string _name, uint _dna) private {
        uint id = zombies.push(Zombie(_name, _dna)) - 1;
        // En version récente, il faut écrire : emit NewZombie(id, _name, _dna);
        NewZombie(id, _name, _dna);
    }

    // Fonction interne pour générer un ADN pseudo-aléatoire à partir d'une chaîne
    // En version récente, utiliser 'string memory _str' et 'keccak256(abi.encodePacked(_str))'
    function _generateRandomDna(string _str) private view returns (uint) {
        uint rand = uint(keccak256(_str));
        return rand % dnaModulus;
    }

    // Fonction publique pour créer un zombie à partir d'un nom
    // En version récente, utiliser 'string memory _name'
    function createRandomZombie(string _name) public {
        uint randDna = _generateRandomDna(_name);
        _createZombie(_name, randDna);
    }

}
