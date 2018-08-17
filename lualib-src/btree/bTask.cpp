#include "bTask.h"

 
bTask::bTask(bNode* node):node(node)
{
}


bTask::~bTask()
{
}

void bTask::addMonster(string id, int data)
{
	monsters.insert(pair<string,int>(id, data));
}

bool bTask::Tick(string id)
{
	this->node->doUpdate();
	return true;
}
void bTask::Init(string path)
{
	/*Json::Reader reader;
	Json::Value root;*/
	/*std::ifstream fs;
	fs.open(path, std::ios::binary);*/

}