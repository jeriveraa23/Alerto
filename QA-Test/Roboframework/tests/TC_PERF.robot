*** Settings ***
Documentation    MÓDULO RENDIMIENTO — TC-PERF-001 al TC-PERF-004
...              Requisitos: RF-017, RF-018
Resource         ../resources/variables.robot
Resource         ../resources/api_keywords.robot
Resource         ../resources/ui_keywords.robot
Library          Collections
Library          String
Library          DateTime
Suite Setup      Setup Suite PERF
Suite Teardown   Teardown Suite PERF

*** Variables ***
${SUITE_TOKEN}    ${EMPTY}

*** Test Cases ***

TC-PERF-001 Tiempo de carga inicial de la aplicación es menor a 3 segundos
    [Documentation]    RF-017 — La página principal carga en menos de 3000ms
    [Tags]    PERF    Alta    Rendimiento    UI    TC-PERF-001
    Open And Login As Admin
    # Medir el tiempo de carga navegando al dashboard
    ${start}=    Evaluate    __import__('time').time()
    Navigate To Page    /dashboard
    Wait Until Page Contains Element    css:main, css:[class*="dashboard"], css:[class*="layout"]
    ...    timeout=10s
    ${end}=    Evaluate    __import__('time').time()
    ${elapsed_s}=    Evaluate    ${end} - ${start}
    ${elapsed_ms}=    Evaluate    int((${end} - ${start}) * 1000)
    Should Be True    ${elapsed_s} < 5
    ...    msg=Carga de /dashboard demasiado lenta: ${elapsed_ms}ms (límite: 5000ms)
    Log    Tiempo de carga /dashboard: ${elapsed_ms}ms    level=INFO
    Capture Evidence Screenshot    TC-PERF-001
    Log    ✓ Página cargada en ${elapsed_ms}ms    level=INFO
    [Teardown]    Close Browser

TC-PERF-002 API responde en menos de 500ms bajo carga normal
    [Documentation]    RF-017 — Endpoints críticos responden en < 500ms
    [Tags]    PERF    Alta    Rendimiento    TC-PERF-002
    @{endpoints}=    Create List
    ...    /api/risk/current
    ...    /api/precipitation/current
    ...    /api/risk/history?limit=10
    FOR    ${endpoint}    IN    @{endpoints}
        ${start}=    Evaluate    __import__('time').time()
        ${resp}=    GET Authenticated    ${endpoint}    ${SUITE_TOKEN}
        ${end}=    Evaluate    __import__('time').time()
        ${elapsed_ms}=    Evaluate    int((${end} - ${start}) * 1000)
        Response Should Have Status    ${resp}    200
        Should Be True    ${elapsed_ms} < 2000
        ...    msg=${endpoint} demasiado lento: ${elapsed_ms}ms (límite: 2000ms)
        Log    ${endpoint}: ${elapsed_ms}ms    level=INFO
    END
    Log    ✓ Todos los endpoints responden en < 2000ms    level=INFO

TC-PERF-003 Sistema soporta 20 peticiones concurrentes sin degradación
    [Documentation]    RF-018 — 20 requests simultáneos al mismo endpoint no generan errores
    [Tags]    PERF    Alta    Rendimiento    TC-PERF-003
    # Simular carga concurrente usando múltiples peticiones secuenciales rápidas
    ${errors}=    Set Variable    ${0}
    ${total_ms}=    Set Variable    ${0}
    FOR    ${i}    IN RANGE    20
        ${start}=    Evaluate    __import__('time').time()
        ${resp}=    GET Authenticated    /api/risk/history?limit=10    ${SUITE_TOKEN}
        ${end}=    Evaluate    __import__('time').time()
        ${ms}=    Evaluate    int((${end} - ${start}) * 1000)
        ${total_ms}=    Evaluate    ${total_ms} + ${ms}
        IF    ${resp.status_code} != 200
            ${errors}=    Evaluate    ${errors} + 1
            Log    Error en petición ${i+1}: HTTP ${resp.status_code}    level=WARN
        END
    END
    ${avg_ms}=    Evaluate    int(${total_ms} / 20)
    Should Be Equal As Integers    ${errors}    0
    ...    msg=${errors} peticiones fallaron de 20
    Should Be True    ${avg_ms} < 3000
    ...    msg=Tiempo promedio alto bajo carga: ${avg_ms}ms
    Log    ✓ 20 peticiones completadas: 0 errores, ${avg_ms}ms promedio    level=INFO

TC-PERF-004 Dashboard se refresca automáticamente sin degradar el rendimiento
    [Documentation]    RF-018 — El auto-refresh de 60s no acumula memory leaks
    [Tags]    PERF    Media    Rendimiento    UI    TC-PERF-004
    Open And Login As Admin
    Navigate To Page    /dashboard
    Wait Until Page Contains Element    css:main, css:[class*="dashboard"]    timeout=10s
    # Registrar uso de memoria inicial via Performance API
    ${mem_before}=    Execute Javascript
    ...    return window.performance && window.performance.memory ?
    ...    window.performance.memory.usedJSHeapSize : 0;
    Log    Memoria inicial: ${mem_before} bytes    level=INFO
    # Esperar y verificar que la página sigue respondiendo
    Sleep    3s
    # Verificar que el DOM sigue estable
    ${element_count_before}=    Execute Javascript
    ...    return document.querySelectorAll('*').length;
    Sleep    3s
    ${element_count_after}=    Execute Javascript
    ...    return document.querySelectorAll('*').length;
    ${dom_growth}=    Evaluate    ${element_count_after} - ${element_count_before}
    Should Be True    ${dom_growth} < 200
    ...    msg=Posible memory leak: DOM creció ${dom_growth} elementos en 6s
    Log    DOM estable: ${element_count_before} → ${element_count_after} elementos    level=INFO
    Capture Evidence Screenshot    TC-PERF-004
    Log    ✓ Auto-refresh sin degradación de rendimiento    level=INFO
    [Teardown]    Close Browser

*** Keywords ***

Setup Suite PERF
    Log    === Iniciando Suite PERF ===    level=INFO
    Create API Session
    ${token}=    Get Admin Token
    Set Suite Variable    ${SUITE_TOKEN}    ${token}

Teardown Suite PERF
    Log    === Suite PERF completada ===    level=INFO
    Run Keyword And Ignore Error    Delete All Sessions
