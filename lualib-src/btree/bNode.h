#ifndef BNODE_H
#define BNODE_H

#include <vector>

using namespace std;
class bNode
{
protected:
	bNode() {};
	~bNode() {};
public:
	virtual bool doUpdate() = 0;
};

#endif