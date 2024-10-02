-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : ven. 27 sep. 2024 à 06:04
-- Version du serveur : 8.3.0
-- Version de PHP : 8.2.18

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `techplan`
--

-- --------------------------------------------------------

--
-- Structure de la table `agenda`
--

DROP TABLE IF EXISTS `agenda`;
CREATE TABLE IF NOT EXISTS `agenda` (
  `id_Agenda` int NOT NULL,
  PRIMARY KEY (`id_Agenda`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `commentaire`
--

DROP TABLE IF EXISTS `commentaire`;
CREATE TABLE IF NOT EXISTS `commentaire` (
  `id_Commentaire` int NOT NULL,
  `Contenu` text NOT NULL,
  PRIMARY KEY (`id_Commentaire`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `connexion`
--

DROP TABLE IF EXISTS `connexion`;
CREATE TABLE IF NOT EXISTS `connexion` (
  `id_Connexion` int NOT NULL,
  `Login` varchar(30) NOT NULL,
  `Mot_De_Passe` varchar(30) NOT NULL,
  PRIMARY KEY (`id_Connexion`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `fichier`
--

DROP TABLE IF EXISTS `fichier`;
CREATE TABLE IF NOT EXISTS `fichier` (
  `id_Fichier` int NOT NULL,
  `Lien` text NOT NULL,
  `Type_Fichier` varchar(100) NOT NULL,
  PRIMARY KEY (`id_Fichier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `intervention`
--

DROP TABLE IF EXISTS `intervention`;
CREATE TABLE IF NOT EXISTS `intervention` (
  `id_Intervention` int NOT NULL,
  `Titre` varchar(30) NOT NULL,
  `DATE` date NOT NULL,
  `Numero_De_Telephone` varchar(30) NOT NULL,
  `Heure` time NOT NULL,
  `Statut` tinyint(1) NOT NULL,
  `Description` varchar(30) NOT NULL,
  `Commentaire` text,
  `id_Signature` int DEFAULT NULL,
  `id_Commentaire` int DEFAULT NULL,
  `id_Fichier` int DEFAULT NULL,
  PRIMARY KEY (`id_Intervention`),
  KEY `id_Signature` (`id_Signature`),
  KEY `id_Commentaire` (`id_Commentaire`),
  KEY `id_Fichier` (`id_Fichier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `signature`
--

DROP TABLE IF EXISTS `signature`;
CREATE TABLE IF NOT EXISTS `signature` (
  `id_Signature` int NOT NULL,
  `date_Signature` date NOT NULL,
  PRIMARY KEY (`id_Signature`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- --------------------------------------------------------

--
-- Structure de la table `technicien`
--

DROP TABLE IF EXISTS `technicien`;
CREATE TABLE IF NOT EXISTS `technicien` (
  `id_Technicien` int NOT NULL,
  `Nom` varchar(30) NOT NULL,
  `Prenom` varchar(30) NOT NULL,
  `Numero_De_Telephone` varchar(30) NOT NULL,
  `Adresse_Mail` varchar(30) NOT NULL,
  `id_Connexion` int DEFAULT NULL,
  `id_Signature` int DEFAULT NULL,
  `id_Agenda` int DEFAULT NULL,
  PRIMARY KEY (`id_Technicien`),
  KEY `id_Connexion` (`id_Connexion`),
  KEY `id_Signature` (`id_Signature`),
  KEY `id_Agenda` (`id_Agenda`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `intervention`
--
ALTER TABLE `intervention`
  ADD CONSTRAINT `intervention_ibfk_1` FOREIGN KEY (`id_Signature`) REFERENCES `signature` (`id_Signature`) ON DELETE CASCADE,
  ADD CONSTRAINT `intervention_ibfk_2` FOREIGN KEY (`id_Commentaire`) REFERENCES `commentaire` (`id_Commentaire`) ON DELETE CASCADE,
  ADD CONSTRAINT `intervention_ibfk_3` FOREIGN KEY (`id_Fichier`) REFERENCES `fichier` (`id_Fichier`) ON DELETE CASCADE;

--
-- Contraintes pour la table `technicien`
--
ALTER TABLE `technicien`
  ADD CONSTRAINT `technicien_ibfk_1` FOREIGN KEY (`id_Connexion`) REFERENCES `connexion` (`id_Connexion`) ON DELETE CASCADE,
  ADD CONSTRAINT `technicien_ibfk_2` FOREIGN KEY (`id_Signature`) REFERENCES `signature` (`id_Signature`) ON DELETE CASCADE,
  ADD CONSTRAINT `technicien_ibfk_3` FOREIGN KEY (`id_Agenda`) REFERENCES `agenda` (`id_Agenda`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
