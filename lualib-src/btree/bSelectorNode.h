#ifndef BSELECTORNODE_H
#define BSELECTORNODE_H
#include "bNode.h"

class bSelectorNode :
	public bNode
{
public:
	bSelectorNode();
	~bSelectorNode();
public:
	void addNode(bNode*);
public:
	virtual bool  doUpdate();
private:
	std::vector<bNode*> nodes;
};

#endif