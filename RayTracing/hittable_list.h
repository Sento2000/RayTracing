#ifndef HITTABLE_LIST_H
#define HITTABLE_LIST_H
#include "aabb.h"
#include "hittable.h"

#include<memory>
#include<vector>

using std::make_shared;
using std::shared_ptr;



class hittable_list :public hittable
{
public:
	std::vector<shared_ptr<hittable>> objects;
	hittable_list() {}
	hittable_list(shared_ptr<hittable> object) { add(object); }
	void clear() { objects.clear(); }
	void add(shared_ptr<hittable>object)
	{
		objects.push_back(object);
		bbox = aabb(bbox, object->bounding_box());//构建一个包围所有物体的包围盒
	}
	//关键函数hit，判定是否击中 
	bool hit(const ray& r, interval ray_t, hit_record& rec)const override
	{
		hit_record temp_rec;
		bool hit_anything = false; //初始默认什么都没击中
		auto closest_so_far = ray_t.max; //最近命中距离初始化为允许击中最远距离
		for (const auto& object : objects)
			//遍历场景中所有物体
		{
			if (object->hit(r, interval(ray_t.min, closest_so_far), temp_rec))
			{
				hit_anything = true;
				closest_so_far = temp_rec.t;
				rec = temp_rec;
			}
		}
		return hit_anything;
	}
	aabb bounding_box() const override { return bbox; }
private:
	aabb bbox;
};

#endif 
