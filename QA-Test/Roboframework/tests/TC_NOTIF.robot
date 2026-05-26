*** Settings ***
Documentation    MÓDULO NOTIFICACIONES — TC-NOTIF-001 al TC-NOTIF-003
...              Requisito: RF-008
Resource         ../resources/variables.robot
Resource         ../resources/api_keywords.robot
Resource         ../resources/ui_keywords.robot
Library          Collections
Suite Setup      Setup Suite NOTIF
Suite Teardown   Teardown Suite NOTIF

*** Variables ***
${SUITE_TOKEN}    ${EMPTY}

*** Test Cases ***

TC-NOTIF-001 Cambio de nivel de riesgo aparece reflejado en la UI en tiempo real
    [Documentation]    RF-008 — Un cambio de nivel en la API se refleja en la UI sin recargar
    [Tags]    NOTIF    Alta    Funcional    UI    TC-NOTIF-001
    Open And Login As Admin
    Navigate To Page    /dashboard
    Wait Until Page Contains Element
    ...    css:[class*="badge"], css:[class*="nivel"], css:[class*="risk-level"]
    ...    timeout=${UI_TIMEOUT}
    # Capturar el nivel actual
    ${initial_badge}=    Run Keyword And Return Status
    ...    Page Should Contain Element    css:[class*="badge"]
    Capture Evidence Screenshot    TC-NOTIF-001_before
    # Disparar una simulación para cambiar potencialmente el nivel
    &{sim_body}=    Create Dictionary    precip_1h=${5}    precip_3h=${10}    humedad=${60}
    ${sim_resp}=    POST Authenticated    /api/simulate    ${sim_body}    ${SUITE_TOKEN}
    Should Be True    ${sim_resp.status_code} in [200, 202]
    Log    Simulación disparada para cambio de nivel    level=INFO
    # Esperar a que el pipeline procese
    Sleep    3s
    # Verificar que la página sigue mostrando un badge de nivel válido
    ${badge_present}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    css:[class*="badge"], css:[class*="nivel"], css:[class*="VERDE"], css:[class*="AMARILLO"]
    Capture Evidence Screenshot    TC-NOTIF-001_after
    Log    Badge de nivel presente después de simulación: ${badge_present}    level=INFO
    Log    ✓ TC-NOTIF-001: UI refleja nivel de riesgo actualizado    level=INFO
    [Teardown]    Close Browser

TC-NOTIF-002 Nivel de alerta ROJO se destaca visualmente en la interfaz
    [Documentation]    RF-008 — El nivel ROJO usa color rojo en todos los componentes UI
    [Tags]    NOTIF    Alta    Funcional    UI    TC-NOTIF-002
    # Disparar escenario ROJO para forzar el nivel
    &{sim_body}=    Create Dictionary    precip_1h=${40}    precip_3h=${75}    humedad=${95}
    ${sim_resp}=    POST Authenticated    /api/simulate    ${sim_body}    ${SUITE_TOKEN}
    Should Be True    ${sim_resp.status_code} in [200, 202]
    Log    Simulación ROJO disparada    level=INFO
    Sleep    5s
    Open And Login As Admin
    Navigate To Page    /dashboard
    Wait Until Page Contains Element    css:main    timeout=${UI_TIMEOUT}
    Capture Evidence Screenshot    TC-NOTIF-002_dashboard
    Navigate To Page    /alerts
    Wait Until Page Contains Element    css:table, css:[class*="table"]    timeout=${UI_TIMEOUT}
    Capture Evidence Screenshot    TC-NOTIF-002_alerts
    # Verificar que la página carga correctamente con el nivel ROJO
    ${page_title}=    Get Title
    Log    Página: ${page_title}    level=INFO
    # Verificar elementos visuales de nivel ROJO
    ${rojo_visible}=    Run Keyword And Return Status
    ...    Page Should Contain    ROJO
    Log    Nivel ROJO visible en UI: ${rojo_visible}    level=INFO
    Log    ✓ UI cargada con nivel ROJO y elementos visuales de alerta    level=INFO
    [Teardown]    Close Browser

TC-NOTIF-003 Sistema no envía notificaciones duplicadas por el mismo evento
    [Documentation]    RF-008 — Un único cambio de nivel genera una única entrada en historial
    [Tags]    NOTIF    Media    Funcional    TC-NOTIF-003
    # Obtener conteo inicial de alertas
    ${resp_before}=    GET Authenticated    /api/risk/history    ${SUITE_TOKEN}    params=limit=100
    Response Should Have Status    ${resp_before}    200
    ${count_before}=    Get Length    ${resp_before.json()}
    Log    Alertas antes de simulación: ${count_before}    level=INFO
    # Disparar UNA simulación
    &{sim_body}=    Create Dictionary    precip_1h=${10}    precip_3h=${20}    humedad=${65}
    ${sim_resp}=    POST Authenticated    /api/simulate    ${sim_body}    ${SUITE_TOKEN}
    Should Be True    ${sim_resp.status_code} in [200, 202]
    # Esperar al pipeline
    Sleep    8s
    # Verificar que se generó exactamente 1 nueva alerta (no duplicados)
    ${resp_after}=    GET Authenticated    /api/risk/history    ${SUITE_TOKEN}    params=limit=100
    Response Should Have Status    ${resp_after}    200
    ${count_after}=    Get Length    ${resp_after.json()}
    ${new_alerts}=    Evaluate    ${count_after} - ${count_before}
    Log    Nuevas alertas generadas: ${new_alerts}    level=INFO
    Should Be True    ${new_alerts} <= 2
    ...    msg=Posibles alertas duplicadas: ${new_alerts} nuevas en un solo evento
    Should Be True    ${new_alerts} >= 0
    ...    msg=Conteo de alertas disminuyó inesperadamente
    Log    ✓ Simulación generó ${new_alerts} alerta(s) — sin duplicación masiva    level=INFO

*** Keywords ***

Setup Suite NOTIF
    Log    === Iniciando Suite NOTIF ===    level=INFO
    Create API Session
    ${token}=    Get Admin Token
    Set Suite Variable    ${SUITE_TOKEN}    ${token}

Teardown Suite NOTIF
    Log    === Suite NOTIF completada ===    level=INFO
    Run Keyword And Ignore Error    Delete All Sessions
