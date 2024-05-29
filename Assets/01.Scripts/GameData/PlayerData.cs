using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerData : CanSaveData
{
    public int level = 4;
    public int exp = 0;
    public string nickName = "น่ม๖ศฃ";

    public int attak = 5;
    public int defination = 3;
    public int heartPoint = 20;

    public override void SetInitialValue()
    {

    }
}
