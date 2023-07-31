// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "AIController.h"
#include "BehaviorTree/BehaviorTree.h"
#include "BehaviorTree/BTTaskNode.h"
#include "MyBTTaskNode.generated.h"

/**
 * 
 */
UCLASS()
class PROJECT_NAME_API UMyBTTaskNode : public UBTTaskNode
{
	GENERATED_BODY()
	
public:
	/** 
	 * starts this task, should return Succeeded, Failed or InProgress
	 * (use FinishLatentTask() when returning InProgress)
	 * this function should be considered as const (don't modify state of object) if node is not instanced!
	 * @param OwnerComp
	 * @param NodeMemory
	 * @returns EBTNodeResult::Type
	 */
	virtual EBTNodeResult::Type ExecuteTask(
		UBehaviorTreeComponent& OwnerCom,
		uint8* NodeMemory
	) override;
};
