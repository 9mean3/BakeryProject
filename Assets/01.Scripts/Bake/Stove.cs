using DG.Tweening;
using ExtensionFunction;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Stove : MonoBehaviour, IBakingProductionObject
{
    public UnityEvent OnEndShaking;
    [SerializeField] private Transform _qMark;
    [SerializeField] private Vector2 _normalScale;

    [SerializeField] private float _normalShkTime = 2f;
    [SerializeField] private float _epicShkTime = 2.5f;
    [SerializeField] private float _legendShkTime = 3.5f;
    public float EasingTime { get; set; } = 0.3f;

    public void OnProduction()
    {
        transform.SmartScale(_normalScale * 1.3f, EasingTime);
    }

    public void ExitProduction()
    {
        transform.SmartScale(_normalScale, EasingTime);
    }

    public void DoughInStove(int grade)
    {
        Debug.Log(grade);

        SpriteRenderer qMarkRenderer = _qMark.GetComponent<SpriteRenderer>();

        Sequence seq = DOTween.Sequence();
        seq.Append(transform.DOScale(_normalScale, 1f));
        seq.Join(transform.DOLocalMoveY(0, 1f));
        for (int i = 0; i < 2; i++)
        {
            int dir = i % 2 == 0 ? 1 : -1;
            seq.Append(_qMark.DOLocalMove(new Vector2(0, -0.5f), 0));
            seq.Append(qMarkRenderer.DOFade(0, 0));

            seq.Append(transform.DORotate(new Vector3(0, 0, dir * 20), EasingTime).SetEase(Ease.OutBack));
            seq.Join(transform.DOMoveX(-dir, EasingTime).SetEase(Ease.OutBack));
            seq.Join(_qMark.DOLocalMove(new Vector2(dir * 5f, 2f), EasingTime + 0.6f).SetEase(Ease.OutCubic));
            seq.Join(_qMark.DORotate(new Vector3(0,0,-dir * 20), EasingTime + 0.4f).SetEase(Ease.InOutBack));
            seq.Join(qMarkRenderer.DOFade(1, EasingTime).SetEase(Ease.OutQuad));

            seq.Append(transform.DORotate(Vector3.zero, EasingTime));
            seq.Join(transform.DOMoveX(0, EasingTime));
            seq.Join(qMarkRenderer.DOFade(0, EasingTime));
        }

        seq.OnComplete(() =>
        {
            switch (grade)
            {
                case 0:
                    {
                        LegendGrade();
                    }
                    break;
                case 1:
                    {
                        EpicGrade();
                    }
                    break;
                case 2:
                    {
                        NormalGrade();
                    }
                    break;
                default:
                    break;
            }
        });
        //seq.Kill();
    }

    private void NormalGrade()
    {
        Sequence seq = DOTween.Sequence();

        seq.Append(transform.DOShakeRotation(_normalShkTime, new Vector3(0, 0, 12f), 10, 10, false, ShakeRandomnessMode.Harmonic));
        seq.Join(transform.DOScale(_normalScale * 0.7f, 2f).SetEase(Ease.OutQuad));
        seq.Join(transform.DOLocalMoveY(0, 2f).SetEase(Ease.OutQuad));

        seq.OnComplete(() =>
        {
            transform.DOScale(_normalScale, 0.5f).SetEase(Ease.InOutBack);
            OnEndShaking.Invoke();
        });
    }

    private void EpicGrade()
    {
        Sequence seq = DOTween.Sequence();

        seq.Append(transform.DOShakeRotation(_normalShkTime, new Vector3(0, 0, 12f), 10, 10, false, ShakeRandomnessMode.Harmonic));
        seq.Join(transform.DOScale(_normalScale * 0.7f, 2f).SetEase(Ease.OutQuad));
        seq.Join(transform.DOLocalMoveY(0, 2f).SetEase(Ease.OutQuad));

        seq.Append(transform.DOScale(_normalScale * 1f, 0.7f).SetEase(Ease.OutQuart));

        seq.Append(transform.DOShakeRotation(_epicShkTime, new Vector3(0, 0, 14f), 10, 10, false, ShakeRandomnessMode.Harmonic));
        seq.Join(transform.DOScale(_normalScale * 0.65f, 2f).SetEase(Ease.OutQuart));

        seq.OnComplete(() =>
        {
            transform.DOScale(_normalScale, 0.5f).SetEase(Ease.InOutBack);
            OnEndShaking.Invoke();
        });
    }

    private void LegendGrade()
    {
        Sequence seq = DOTween.Sequence();

        seq.Append(transform.DOShakeRotation(_normalShkTime, new Vector3(0, 0, 12f), 10, 10, false, ShakeRandomnessMode.Harmonic));
        seq.Join(transform.DOScale(_normalScale * 0.7f, 2f).SetEase(Ease.OutQuad));
        seq.Join(transform.DOLocalMoveY(0, 2f).SetEase(Ease.OutQuad));

        seq.Append(transform.DOScale(_normalScale * 1f, 0.7f).SetEase(Ease.OutQuart));

        seq.Append(transform.DOShakeRotation(_epicShkTime, new Vector3(0, 0, 14f), 10, 10, false, ShakeRandomnessMode.Harmonic));
        seq.Join(transform.DOScale(_normalScale * 0.65f, 2f).SetEase(Ease.OutQuad));

        seq.Append(transform.DOScale(_normalScale * 1.1f, 0.7f).SetEase(Ease.OutQuart));
        seq.Join(transform.DORotate(new Vector3(0, 720, 0), 1.5f, RotateMode.FastBeyond360).SetEase(Ease.OutQuart));
        

        seq.Append(transform.DOShakeRotation(_legendShkTime, new Vector3(0, 0, 17f), 10, 10, false, ShakeRandomnessMode.Harmonic));
        seq.Join(transform.DOScale(_normalScale * 0.6f, 2f).SetEase(Ease.OutQuad));

        seq.OnComplete(() =>
        {
            transform.DOScale(_normalScale, 0.5f).SetEase(Ease.InOutBack);
            OnEndShaking.Invoke();
        });
    }
}
