//
//  InitialMantraData.swift
//  ReadTheMantra
//
//  Created by Александр Воробьев on 10.08.2020.
//  Copyright © 2020 Александр Воробьев. All rights reserved.
//

import Foundation

enum MantraKey {
    case title
    case text
    case details
    case image
}

struct InitialMantra {
    static let data: [Int: [MantraKey: String]] = [
        0:
            [
            .title: NSLocalizedString("Buddha Shakyamuni", comment: "Buddha Shakyamuni"),
            .details: NSLocalizedString("Thanks to the repetition of this mantra, all obscurations and hindrances go away, a person approaches the state of Enlightenment, receives inspiration, blessings, rapid progress on the path of perfection, and a connection is established with Buddha Shakyamuni.", comment: "Buddha Shakyamuni Description"),
            .image: "Buddha_Shakyamuni"
            ],
        1:
            [
            .title: NSLocalizedString("Buddha Medicine", comment: "Buddha Medicine"),
            .details: NSLocalizedString("Reading a mantra creates a special vibration that affects energy channels, expands and purifies the aura, enhances vital energy, including the mantra helps to transform negative emotions and obscurations.", comment: "Buddha Medicine Description"),
            .image: "Buddha_Medicine"
            ],
        2:
            [
            .title: NSLocalizedString("Buddha Amitabha", comment: "Buddha Amitabha"),
            .details: NSLocalizedString("Reading a mantra personifies the discriminating mind and bestows the yogic power of knowing each thing separately, as well as all things in unity.", comment: "Buddha Amitabha Description"),
            .image: "Buddha_Amitabha"
            ],
        3:
            [
            .title: NSLocalizedString("Avalokitesvara", comment: "Avalokitesvara"),
            .details: NSLocalizedString("Repetition of the mantra in concentration clears negative karma, affects all levels of the subconscious, reveals hidden talents, allows you to accumulate vast merits, develop compassion and kind-heartedness towards all living beings.", comment: "Avalokitesvara Description"),
            .image: "Avalokitesvara"
            ],
        4:
            [
            .title: NSLocalizedString("Vajrapani", comment: "Vajrapani"),
            .details: NSLocalizedString("Reciting the mantra of the bodhisattva Vajrapani with sincere good intentions helps to overcome various ailments, delusions, brings self-confidence, firm support in any endeavors, determination, purposefulness, increases the strength and capabilities of a person.", comment: "Vajrapani Description"),
            .image: "Vajrapani"
            ],
        5:
            [
            .title: NSLocalizedString("Vasundhara", comment: "Vasundhara"),
            .details: NSLocalizedString("Bestows piously acquired wealth and also ensures that spiritual wisdom is accompanied by favorable circumstances: a high standard of living, longevity, and happiness.", comment: "Vasundhara Description"),
            .image: "Vasundhara"
            ],
        6:
            [
            .title: NSLocalizedString("Hayagriva", comment: "Hayagriva"),
            .details: NSLocalizedString("Hayagriva's mantra prevents suicide, murder, protects against the action of harmful spirits and evil demons, promotes peace and tranquility in the soul. The mantra of the protector protects not only from spirits and evil demons, but also from backbiting and slander.", comment: "Hayagriva Description"),
            .image: "Hayagriva"
            ],
        7:
            [
            .title: NSLocalizedString("Manjusri", comment: "Manjusri"),
            .details: NSLocalizedString("Reading a mantra dispels the roots of ignorance and defilement, develops wisdom, intelligence, assimilation of knowledge, strengthens memory, develops eloquence, allows you to control the mind and contributes to comprehending the true nature of all things.", comment: "Manjusri Description"),
            .image: "Manjusri"
            ],
        8:
            [
            .title: NSLocalizedString("Green Tara", comment: "Green Tara"),
            .details: NSLocalizedString("Green Tara is addressed as the embodiment of all enlightened ones, as a comforter, as a protector who quickly responds to a request for help, as a patronizing deity who shows compassion and love to all beings, comparable to a mother's care for her children.", comment: "Green Tara Description"),
            .image: "Green_Tara"
            ],
        9:
            [
            .title: NSLocalizedString("Vajrasattva", comment: "Vajrasattva"),
            .text: NSLocalizedString("OM BENZA SATO SAMAYA MANUPALAYA BENZA SATO TENOPA TITA DRI DO MEBHAWA SUTO KAYO MEBHAWA SUPO KAYO MEBHAWA ANURAKTO MEBHAWA SARWA SIDDHI MEMTRAYATSA SARWA KARMA SUTSA METSI TAM SHRI YA KURU HUNG HA HA HA HA HO BHAGAWAN SARWA TATHAGATA BENZA MA ME MUNTSA BENZRI BHAWA MAHA SAMAYA SATO AH", comment: "Vajrasattva Text"),
            .details: NSLocalizedString("The practice of the Vajrasattva mantra has the ability to purify the karma of not only this incarnation, but also many others, bring peace, alleviate the suffering of the reader or listener, remove spiritual obstacles and cause enlightenment in general.", comment: "Vajrasattva Description"),
            .image: "Vajrasattva"
            ]
        ]
}
