pragma solidity ^0.4.19; // Utilise une version plus récente si possible (ex: ^0.8.0)

// Contrat principal pour gérer la création des zombies
contract ZombieFactory {

    // Événement déclenché lorsqu’un zombie est créé
    // Le front-end peut "écouter" cet événement pour réagir en temps réel
    event NewZombie(uint zombieId, string name, uint dna);

    // Nombre de chiffres souhaités pour l’ADN (ici : 16 chiffres)
    uint dnaDigits = 16;

    // Calcul de la valeur max pour un ADN de 16 chiffres
    // Cela servira à tronquer l’ADN si jamais il est trop grand
    uint dnaModulus = 10 ** dnaDigits;

    // Structure représentant un zombie : un nom et un ADN
    struct Zombie {
        string name;
        uint dna;
    }

    // Tableau dynamique qui stocke tous les zombies créés
    Zombie[] public zombies;

    // Association entre un ID de zombie et l’adresse de son propriétaire
    mapping (uint => address) public zombieToOwner;

    // Compte combien de zombies possède chaque propriétaire
    mapping (address => uint) ownerZombieCount;

    // Fonction interne pour créer un zombie
    // - `_name` : nom du zombie
    // - `_dna` : ADN (unique) du zombie
    function _createZombie(string _name, uint _dna) internal {
        // Ajoute le nouveau zombie au tableau et récupère son index comme ID
        uint id = zombies.push(Zombie(_name, _dna)) - 1;

        // On enregistre qui est le propriétaire du zombie
        zombieToOwner[id] = msg.sender;

        // Incrémente le compteur de zombies pour cet utilisateur
        ownerZombieCount[msg.sender]++;

        // Déclenche l’événement (sans 'emit' car version < 0.4.21)
        NewZombie(id, _name, _dna);
    }

    // Fonction privée pour générer un ADN pseudo-aléatoire à partir d’une chaîne
    // - `_str` : une chaîne de texte, en général le nom du zombie
    // Retourne un nombre à 16 chiffres max
    function _generateRandomDna(string _str) private view returns (uint) {
        // Crée un hash de la chaîne, puis convertit en uint
        uint rand = uint(keccak256(_str));

        // Tronque pour que l’ADN ne dépasse pas 16 chiffres
        return rand % dnaModulus;
    }

    // Fonction publique pour créer un zombie avec un nom personnalisé
    // Elle n’autorise qu’un seul zombie par adresse (grâce au require)
    function createRandomZombie(string _name) public {
        // Vérifie que l'utilisateur ne possède pas déjà un zombie
        require(ownerZombieCount[msg.sender] == 0);

        // Génère un ADN pseudo-aléatoire à partir du nom
        uint randDna = _generateRandomDna(_name);

        // Supprime les 2 derniers chiffres (sert à personnaliser l’ADN ensuite)
        randDna = randDna - randDna % 100;

        // Crée le zombie avec le nom et l'ADN calculé
        _createZombie(_name, randDna);
    }

}