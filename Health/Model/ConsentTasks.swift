//
//  ConsentTasks.swift
//  Health
//
//  Created by Vikhyath on 20/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import ResearchKit

public var ConsentTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    steps += [visualConsentStep]

    //Add ConsentReviewStep
    if let signatureUnwrapped = consentDocument.signatures {
        let signature = signatureUnwrapped.first
        let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)
        reviewConsentStep.text = "Review Consent!"
        reviewConsentStep.reasonForConsent = "Consent to join study"
        steps += [reviewConsentStep]
    }
    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
