﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GlobalWind : MonoBehaviour {

    [Header("Wind Attributes")]
    [Space(10)]
    [SerializeField]
    [Range(0f, 10f)]
    float windStrength = 1f;
    [SerializeField]
    [Range(0f, 10f)]
    float turbulence = 1f;
    [SerializeField]
    float windChangeInterval = 15f;

    float startTime;
    Vector4 wind;
    Vector4 targetWind;

    void Start () {
        wind = getRandomWind();
        StartCoroutine(changeWind());
    }

    void Update () {

        float time = (Time.time - startTime) / windChangeInterval;
        Vector4 currentWind = Vector4.Lerp(wind, targetWind, 0.5f * ( 1f - Mathf.Cos(Mathf.PI * time) ));
        currentWind *= Mathf.PerlinNoise(Time.time * turbulence / 5f, 0f);
        Shader.SetGlobalVector("_Wind", currentWind);
    }

    IEnumerator changeWind () {

        while (gameObject.activeInHierarchy) {

            startTime = Time.time;
            wind = targetWind;
            targetWind = getRandomWind();
            yield return new WaitForSeconds(windChangeInterval);
        }
    }

    Vector4 getRandomWind () {

        return new Vector4(Random.value - 0.5f, (Random.value - 0.5f) / 10f, Random.value - 0.5f) * windStrength;
    }
}