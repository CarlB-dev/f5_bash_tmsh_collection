This is the library of commands used for https://my.f5.com/manage/s/article/K000149084 

General discussion of the commands and how they are formatted is here - https://community.f5.com/discussions/TechnicalForum/removing-aamwam-for-a-successful-upgrade/339378

> While these are provided as shell script files, they are not intended to be used as full script imported and ran on your BIG-IP


# [Inventory of AAM objects](/aam_removal/aam_objects_inventory.sh)

These commands are strictly meant to assess and catalog any items that will need to be changed.

> These commands **DO NOT** change or modify any objects

[Explanation of commands](/aam_removal/inventory_README.md)

# [Modify and Delete AAM Objects](/aam_removal/aam_objects_modify_or_delete.sh)

These commands will immediately modify and delete AAM objects. The commands do output to the terminal any commands that they ran, for you to capture what was done or to see which command encountered errors.

> **Only use this during a change window**

[Explanation of commands](/aam_removal/modify_delete_README.md)

# [Full library of commands to inventory and modify/delete AAM Objects](/aam_removal/aam_removal_for_upgrades_all.sh)

This file contains the inventory commands followed by the modify/delete commands described above.

> **This is for reference only as it will do both inventory and then modify/delete**