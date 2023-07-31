#include "UMyBTTaskNode.h"

/** 
 * starts this task, should return Succeeded, Failed or InProgress
 * (use FinishLatentTask() when returning InProgress)
 * this function should be considered as const (don't modify state of object) if node is not instanced!
 * @param OwnerComp
 * @param NodeMemory
 * @returns EBTNodeResult::Type
 */
EBTNodeResult::Type UMyBTTaskNode::ExecuteTask(
	UBehaviorTreeComponent& OwnerComp,
	uint8* NodeMemory
)
{
	return EBTNodeResult::Succeeded;
}
