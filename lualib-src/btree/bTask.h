#ifndef BTASK_H
#define BTASK_H
#include "bNode.h"
#include <map>
extern "C" {
	class bTask;
}
class bTask
{
public:
	bTask(bNode*);
	~bTask();
public:
	void Init(string);
	bool Tick(string);
	void addMonster(string, int);
private:
	bNode * node;
	map<string, int> monsters;
};

#endif