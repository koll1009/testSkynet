#ifndef BPATROLNODE_H
#define BPATROLNODE_H

#include "bNode.h"
class bPatrolNode :
	public bNode
{
public:
	bPatrolNode();
	~bPatrolNode();
public:
	virtual bool doUpdate();
	bool test() {
		
	}
};

#endif