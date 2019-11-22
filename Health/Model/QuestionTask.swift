//
//  QuestionTask.swift
//  Health
//
//  Created by Vikhyath on 26/09/18.
//  Copyright © 2018 Vikhyath. All rights reserved.
//

import Foundation
import ResearchKit

public var QuestionTask: ORKOrderedTask {
    
    var steps = [ORKStep]()
    
    let instructionStep = ORKInstructionStep(identifier: "IntroStep")
    instructionStep.title = "The Questionary survey"
    instructionStep.text = "You just need to ask couple of question that we need to know to give you suggestions"
    steps += [instructionStep]
    
    let nameAnswerFormat = ORKTextAnswerFormat(maximumLength: 2)
    nameAnswerFormat.multipleLines = false
    nameAnswerFormat.keyboardType = .numberPad
    let nameQuestionStepTitle = "How many litres of water did you drink today?"
    let nameQuestionStep = ORKQuestionStep(identifier: "water", title: nameQuestionStepTitle, answer: nameAnswerFormat)
    steps += [nameQuestionStep]
    
    let workHoursQuestion = ORKTextAnswerFormat(maximumLength: 20)
    workHoursQuestion.multipleLines = false
    workHoursQuestion.keyboardType = .numberPad
    let workQuestionStepTitle = "How many hours did you work today?"
    let workQuestionStep = ORKQuestionStep(identifier: "work", title: workQuestionStepTitle, answer: workHoursQuestion)
    steps += [workQuestionStep]
    
    let illnessQuestion = ORKTextAnswerFormat(maximumLength: 20)
    illnessQuestion.multipleLines = false
    let illnessQuestionStepTitle = "Are you suffering from any illness, if so, mention the same?"
    let illnessQuestionStep = ORKQuestionStep(identifier: "illness", title: illnessQuestionStepTitle, answer: illnessQuestion)
    steps += [illnessQuestionStep]
    
    let questQuestionStepTitle = "Are you sick today?"
    let textChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let questAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
    let questQuestionStep = ORKQuestionStep(identifier: "TextChoiceQuestionStep", title: questQuestionStepTitle, answer: questAnswerFormat)
    steps += [questQuestionStep]

    //Question 2
    let foodQuestionType = "Did you eat junk food today?"
    let foodtextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let foodAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: foodtextChoices)
    let foodQuestionStep = ORKQuestionStep(identifier: "foodQuestion", title: foodQuestionType, answer: foodAnswerFormat)
    steps += [foodQuestionStep]
    
    //Question 3
    let stressQuestionType = "Did you feel stressed today?"
    let stressTextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let stressAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: stressTextChoices)
    let stressQuestionStep = ORKQuestionStep(identifier: "stressQuestion", title: stressQuestionType, answer: stressAnswerFormat)
    steps += [stressQuestionStep]
        
    //Question 4
    let sleepQuestionType = "Did you have enough sleep today?"
    let sleepTextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let sleepAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: sleepTextChoices)
    let sleepQuestionStep = ORKQuestionStep(identifier: "sleepQuestion", title: sleepQuestionType, answer: sleepAnswerFormat)
    steps += [sleepQuestionStep]
    
    let alcoholQuestionType = "Did you have alcohol today?"
    let alcoholTextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let alcoholAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: alcoholTextChoices)
    let alcoholQuestionStep = ORKQuestionStep(identifier: "alcoholQuestion", title: alcoholQuestionType, answer: alcoholAnswerFormat)
    steps += [alcoholQuestionStep]
    
    let smokeQuestionType = "Did you smoke today?"
    let smokeTextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let smokeAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: smokeTextChoices)
    let smokeQuestionStep = ORKQuestionStep(identifier: "smokeQuestion", title: smokeQuestionType, answer: smokeAnswerFormat)
    steps += [smokeQuestionStep]
    
    let exerciseQuestionType = "Did you have enough exercise today?"
    let exerciseTextChoices = [
        ORKTextChoice(text: "Yes", value: "1" as NSString),
        ORKTextChoice(text: "No", value: "0" as NSString)
    ]
    let exerciseAnswerFormat: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: exerciseTextChoices)
    let exerciseQuestionStep = ORKQuestionStep(identifier: "exerciseQuestion", title: exerciseQuestionType, answer: exerciseAnswerFormat)
    steps += [exerciseQuestionStep]
    
    let summaryStep = ORKCompletionStep(identifier: "SummaryStep")
    summaryStep.title = "Right. Off you go!"
    summaryStep.text = "That was easy!"
    steps += [summaryStep]

    return ORKOrderedTask(identifier: "QuestionTask", steps: steps)
}
