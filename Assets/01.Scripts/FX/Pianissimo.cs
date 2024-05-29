using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class Pianissimo : MonoBehaviour
{
    private Transform _target;

    private void Start()
    {
        Ready();
    }

    private void Ready()
    {
        Vector3 dir = (transform.position - _target.position).normalized;
        Quaternion quat = Quaternion.LookRotation(dir);

        Sequence seq = DOTween.Sequence();
        seq.Append(transform.DORotateQuaternion(quat, 1.0f));
        seq.AppendCallback(() =>
        {
            Attack();
        });
    }

    private void Attack()
    {
        
    }
}
