using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using System;
using UnityEngine.EventSystems;

public class CheckBox : MonoBehaviour, IPointerClickHandler
{
    [SerializeField] private Image _activationMark;
    public Action<bool> OnValueChanged;
    private bool _isActive;
    public bool IsActive
    {
        get
        {
            return _isActive;
        }
        set
        {
            _isActive = value;
            _activationMark.enabled = _isActive;
            OnValueChanged?.Invoke(_isActive);
        }
    }

    public void OnPointerClick(PointerEventData eventData)
    {
        IsActive = !IsActive;
    }
}
