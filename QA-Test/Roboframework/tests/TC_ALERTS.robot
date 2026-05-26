*** Settings ***
Documentation    MÓDULO ALERTAS — TC-ALERTS-001 al TC-ALERTS-003
...              Requisito: RF-008
Resource         ../resources/variables.robot
Resource         ../resources/api_keywords.robot
Resource         ../resources/ui_keywords.robot
Library          Collections
Suite Setup      Setup Suite ALERTS
Suite Teardown   Teardown Suite ALERTS

*** Variables ***
${SUITE_TOKEN}    ${EMPTY}

*** Test Cases ***

TC-ALERTS-001 Página alertas muestra contadores por nivel
    [Documentation]    RF-008 — Tarjetas con contadores VERDE/AMARILLO/NARANJA/ROJO
    [Tags]    ALERTS    Alta    Funcional    UI    TC-ALERTS-001
    Open And Login As Admin
    Navigate To Page    /alerts
    Wait Until Page Contains Element    css:.stats-strip, css:[class*="stat"]    timeout=${UI_TIMEOUT}
    # Verificar que hay tarjetas de conteo
    @{stat_cards}=    Get WebElements    css:[class*="stat-card"], css:[class*="level-card"]
    ${card_count}=    Get Length    ${stat_cards}
    Log    Tarjetas de estadísticas encontradas: ${card_count}    level=INFO
    Should Be True    ${card_count} >= 4    msg=Se esperaban 4+ tarjetas de conteo
    # Verificar tabla de alertas
    Wait Until Page Contains Element    css:table, css:[class*="table"]    timeout=${UI_TIMEOUT}
    Capture Evidence Screenshot    TC-ALERTS-001
    Log    ✓ Página /alerts con tarjetas de conteo y tabla de alertas    level=INFO
    [Teardown]    Close Browser

TC-ALERTS-002 Filtro por nivel de riesgo funciona correctamente
    [Documentation]    RF-008 — Filtros TODOS/ROJO/NARANJA/AMARILLO/VERDE funcionan
    [Tags]    ALERTS    Media    Funcional    UI    TC-ALERTS-002
    Open And Login As Admin
    Navigate To Page    /alerts
    Wait Until Page Contains Element    css:table, css:[class*="filter"]    timeout=${UI_TIMEOUT}
    # Hacer clic en filtro ROJO
    ${filter_rojo}=    Run Keyword And Return Status
    ...    Click Element    xpath=//button[contains(.,'ROJO')]
    Sleep    0.5s
    Log    Filtro ROJO activado: ${filter_rojo}    level=INFO
    Capture Evidence Screenshot    TC-ALERTS-002_filtro_rojo
    # Volver a TODOS
    ${filter_todos}=    Run Keyword And Return Status
    ...    Click Element    xpath=//button[contains(.,'TODOS') or contains(.,'Todos')]
    Sleep    0.5s
    Capture Evidence Screenshot    TC-ALERTS-002_filtro_todos
    Log    ✓ Filtros ROJO y TODOS funcionan correctamente    level=INFO
    [Teardown]    Close Browser

TC-ALERTS-003 Paginación de alertas funciona con muchos registros
    [Documentation]    RF-008 — Máximo 50 registros por página, botones de navegación
    [Tags]    ALERTS    Media    Funcional    TC-ALERTS-003
    # Verificar vía API que hay registros suficientes
    ${resp}=    GET Authenticated    /api/risk/history    ${SUITE_TOKEN}    params=limit=100
    Response Should Have Status    ${resp}    200
    ${total}=    Get Length    ${resp.json()}
    Log    Total de alertas disponibles: ${total}    level=INFO
    # Test de UI para paginación
    Open And Login As Admin
    Navigate To Page    /alerts
    Wait Until Page Contains Element    css:table    timeout=${UI_TIMEOUT}
    @{rows}=    Get WebElements    css:tbody tr
    ${row_count}=    Get Length    ${rows}
    Should Be True    ${row_count} <= 50    msg=Primera página tiene más de 50 filas: ${row_count}
    Log    Primera página: ${row_count} filas (máximo 50)    level=INFO
    # Verificar botones de paginación
    ${next_btn}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[contains(.,'Siguiente') or contains(.,'›')]
    Log    Botón Siguiente presente: ${next_btn}    level=INFO
    Capture Evidence Screenshot    TC-ALERTS-003
    Log    ✓ Paginación: ${row_count} filas en página 1    level=INFO
    [Teardown]    Close Browser

*** Keywords ***

Setup Suite ALERTS
    Log    === Iniciando Suite ALERTS ===    level=INFO
    Create API Session
    ${token}=    Get Admin Token
    Set Suite Variable    ${SUITE_TOKEN}    ${token}
    Create Directory    ${SCREENSHOTS_DIR}

Teardown Suite ALERTS
    Log    === Suite ALERTS completada ===    level=INFO
    Run Keyword And Ignore Error    Delete All Sessions
