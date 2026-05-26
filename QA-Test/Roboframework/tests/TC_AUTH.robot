*** Settings ***
Documentation    MÓDULO AUTENTICACIÓN — TC-AUTH-001 al TC-AUTH-013
...              Requisitos: RF-014, RF-015, RF-016
...              Tipos: Funcional, Seguridad
...              Herramientas: RequestsLibrary (API), SeleniumLibrary (UI)
Resource         ../resources/variables.robot
Resource         ../resources/api_keywords.robot
Resource         ../resources/ui_keywords.robot
Suite Setup      Setup Suite AUTH
Suite Teardown   Teardown Suite AUTH

*** Variables ***
${SUITE_TOKEN}      ${EMPTY}
${UNIQUE_EMAIL}     ${EMPTY}

*** Test Cases ***

TC-AUTH-001 Registro exitoso de nuevo usuario
    [Documentation]    RF-014, RF-015 — Registro con datos válidos debe crear usuario con rol 'usuario'
    [Tags]    AUTH    Alta    Funcional    TC-AUTH-001
    ${email}=    Generate Unique Email
    &{body}=    Create Dictionary
    ...    nombre=QA Robot User
    ...    email=${email}
    ...    password=Test1234!
    ...    security_question=${TEST_QUESTION}
    ...    security_answer=${TEST_ANSWER}
    ${resp}=    POST Json    /api/auth/register    ${body}
    Response Should Have Status    ${resp}    201
    Response Body Should Contain Key    ${resp}    access_token
    ${payload}=    Decode JWT Payload    ${resp.json()['access_token']}
    Should Be Equal As Strings    ${payload['role']}    usuario
    Log    ✓ Usuario registrado: ${email}, role=usuario    level=INFO

TC-AUTH-002 Registro con email duplicado es rechazado
    [Documentation]    RF-014 — Email ya registrado debe retornar HTTP 400
    [Tags]    AUTH    Alta    Funcional    TC-AUTH-002
    &{body}=    Create Dictionary
    ...    nombre=Duplicado Test
    ...    email=${ADMIN_EMAIL}
    ...    password=Test1234!
    ...    security_question=${TEST_QUESTION}
    ...    security_answer=${TEST_ANSWER}
    ${resp}=    POST Json    /api/auth/register    ${body}
    Response Should Have Status    ${resp}    400
    ${detail}=    Get From Dictionary    ${resp.json()}    detail
    Should Contain    ${detail}    correo
    Log    ✓ HTTP 400 con mensaje: ${detail}    level=INFO

TC-AUTH-003 Registro con contraseña corta es rechazado
    [Documentation]    RF-014 — Contraseña < 6 caracteres debe retornar HTTP 422
    [Tags]    AUTH    Media    Funcional    TC-AUTH-003
    ${email}=    Generate Unique Email
    &{body}=    Create Dictionary
    ...    nombre=Short Pass Test
    ...    email=${email}
    ...    password=abc
    ...    security_question=${TEST_QUESTION}
    ...    security_answer=${TEST_ANSWER}
    ${resp}=    POST Json    /api/auth/register    ${body}
    Response Should Have Status    ${resp}    422
    Log    ✓ HTTP 422 para contraseña corta    level=INFO

TC-AUTH-004 Login exitoso con credenciales válidas
    [Documentation]    RF-014, RF-015 — Login admin retorna JWT con claims correctos
    [Tags]    AUTH    Alta    Funcional    TC-AUTH-004
    &{body}=    Create Dictionary    email=${ADMIN_EMAIL}    password=${ADMIN_PASS}
    ${resp}=    POST Json    /api/auth/login    ${body}
    Response Should Have Status    ${resp}    200
    Response Body Should Contain Key    ${resp}    access_token
    ${token}=    Get From Dictionary    ${resp.json()}    access_token
    ${payload}=    Decode JWT Payload    ${token}
    Should Contain    ${payload}    sub
    Should Contain    ${payload}    role
    Should Contain    ${payload}    exp
    Should Be Equal As Strings    ${payload['role']}    administrador
    Log    ✓ JWT claims correctos: role=${payload['role']}    level=INFO

TC-AUTH-005 Login con contraseña incorrecta es rechazado
    [Documentation]    RF-014 — Credenciales inválidas deben retornar HTTP 401 con mensaje genérico
    [Tags]    AUTH    Alta    Funcional    Seguridad    TC-AUTH-005
    &{body}=    Create Dictionary
    ...    email=${ADMIN_EMAIL}    password=contraseña_incorrecta_xyz
    ${resp}=    POST Json    /api/auth/login    ${body}
    Response Should Have Status    ${resp}    401
    ${detail}=    Get From Dictionary    ${resp.json()}    detail
    Should Not Contain    ${detail}    no existe
    Should Not Contain    ${detail}    not found
    Log    ✓ HTTP 401 mensaje genérico: ${detail}    level=INFO

TC-AUTH-006 Cierre de sesión elimina token y redirige al login
    [Documentation]    RF-015 — Logout debe limpiar token y bloquear rutas protegidas
    [Tags]    AUTH    Alta    Funcional    UI    TC-AUTH-006
    Open And Login As Admin
    Wait Until Page Contains Element    css:.topbar    timeout=${UI_TIMEOUT}
    ${token_antes}=    Get Local Storage Token
    Should Not Be Empty    ${token_antes}
    Click Element    css:[aria-label="Cerrar sesión"]
    Wait Until Location Is    ${FRONTEND_URL}/login    timeout=${UI_TIMEOUT}
    Local Storage Should Be Empty
    Go To    ${FRONTEND_URL}/risk
    Wait Until Location Contains    /login    timeout=${UI_TIMEOUT}
    Capture Evidence Screenshot    TC-AUTH-006
    Log    ✓ Token eliminado, rutas protegidas redirigen a /login    level=INFO
    [Teardown]    Close Browser

TC-AUTH-007 Acceso sin sesión redirige a login
    [Documentation]    RF-015 — Sin token, todas las rutas protegidas redirigen a /login
    [Tags]    AUTH    Alta    Seguridad    TC-AUTH-007
    Open Alerto Browser    /risk
    Wait Until Location Contains    /login    timeout=${UI_TIMEOUT}
    Go To    ${FRONTEND_URL}/admin
    Wait Until Location Contains    /login    timeout=${UI_TIMEOUT}
    Go To    ${FRONTEND_URL}/simulator
    Wait Until Location Contains    /login    timeout=${UI_TIMEOUT}
    Capture Evidence Screenshot    TC-AUTH-007
    Log    ✓ Todas las rutas protegidas redirigen a /login    level=INFO
    [Teardown]    Close Browser

TC-AUTH-008 Usuario regular no puede acceder a rutas de admin
    [Documentation]    RF-015 (RBAC) — Rol 'usuario' bloqueado por AdminRoute y API
    [Tags]    AUTH    Alta    Seguridad    TC-AUTH-008
    # Registrar usuario regular
    ${email}=    Generate Unique Email
    &{reg}=    Create Dictionary
    ...    nombre=Usuario Regular QA
    ...    email=${email}    password=Test1234!
    ...    security_question=${TEST_QUESTION}    security_answer=${TEST_ANSWER}
    ${reg_resp}=    POST Json    /api/auth/register    ${reg}
    Response Should Have Status    ${reg_resp}    201
    ${user_token}=    Get From Dictionary    ${reg_resp.json()}    access_token
    # API: GET /api/admin/users con token de usuario regular
    ${resp}=    GET Authenticated    /api/admin/users    ${user_token}
    Response Should Have Status    ${resp}    403
    ${detail}=    Get From Dictionary    ${resp.json()}    detail
    Should Contain    ${detail}    administradores
    Log    ✓ HTTP 403 para usuario regular en ruta admin    level=INFO

TC-AUTH-009 Token JWT expirado es rechazado
    [Documentation]    RF-015 — Token con exp pasado debe retornar HTTP 401
    [Tags]    AUTH    Alta    Seguridad    TC-AUTH-009
    # Construir JWT con exp en el pasado
    ${expired_token}=    Evaluate
    ...    __import__('jwt').encode({'sub':'test@test.com','id':999,'name':'Test','role':'usuario','exp':1000000000}, 'alerto_secret', algorithm='HS256')
    ${resp}=    GET Authenticated    /api/risk/current    ${expired_token}
    Response Should Have Status    ${resp}    401
    Log    ✓ HTTP 401 para token expirado    level=INFO

TC-AUTH-010 Cuenta desactivada no puede iniciar sesión
    [Documentation]    RF-015 — Usuario con is_active=false rechazado en login
    [Tags]    AUTH    Alta    Funcional    TC-AUTH-010
    # Crear usuario, desactivar, intentar login
    ${email}=    Generate Unique Email
    &{reg}=    Create Dictionary    nombre=Desactivado QA    email=${email}
    ...    password=Test1234!    security_question=${TEST_QUESTION}    security_answer=${TEST_ANSWER}
    ${reg_resp}=    POST Json    /api/auth/register    ${reg}
    ${reg_data}=    Set Variable    ${reg_resp.json()}
    ${user_id}=    Get From Dictionary    ${reg_data}    user_id
    # Desactivar vía API admin
    &{patch}=    Create Dictionary    is_active=${False}
    ${deact}=    PATCH Authenticated    /api/admin/users/${user_id}/status    ${patch}    ${SUITE_TOKEN}
    Response Should Have Status    ${deact}    200
    # Intentar login
    &{login}=    Create Dictionary    email=${email}    password=Test1234!
    ${resp}=    POST Json    /api/auth/login    ${login}
    Response Should Have Status    ${resp}    401
    ${detail}=    Get From Dictionary    ${resp.json()}    detail
    Should Contain    ${detail}    desactivada
    Log    ✓ Cuenta desactivada: login rechazado HTTP 401    level=INFO

TC-AUTH-011 Recuperación contraseña paso 1 muestra pregunta de seguridad
    [Documentation]    RF-016 — POST con email válido retorna la pregunta de seguridad
    [Tags]    AUTH    Alta    Funcional    TC-AUTH-011
    &{body}=    Create Dictionary    email=${ADMIN_EMAIL}
    ${resp}=    POST Json    /api/auth/reset-password/question    ${body}
    Response Should Have Status    ${resp}    200
    Response Body Should Contain Key    ${resp}    security_question
    ${question}=    Get From Dictionary    ${resp.json()}    security_question
    Should Not Be Empty    ${question}
    Log    ✓ Pregunta de seguridad obtenida: ${question}    level=INFO

TC-AUTH-012 Recuperación contraseña paso 2 cambia la contraseña exitosamente
    [Documentation]    RF-016 — Respuesta correcta + nueva contraseña deben actualizar la BD
    [Tags]    AUTH    Alta    Funcional    TC-AUTH-012
    # Usar usuario de prueba creado en setup
    &{body}=    Create Dictionary
    ...    email=${TEST_EMAIL}
    ...    security_answer=${TEST_ANSWER}
    ...    new_password=NuevaPassRobot99!
    ${resp}=    POST Json    /api/auth/reset-password    ${body}
    Response Should Have Status    ${resp}    200
    # Verificar login con nueva contraseña
    &{login}=    Create Dictionary    email=${TEST_EMAIL}    password=NuevaPassRobot99!
    ${login_resp}=    POST Json    /api/auth/login    ${login}
    Response Should Have Status    ${login_resp}    200
    # Restaurar contraseña original
    &{restore}=    Create Dictionary
    ...    email=${TEST_EMAIL}    security_answer=${TEST_ANSWER}    new_password=${TEST_PASS}
    POST Json    /api/auth/reset-password    ${restore}
    Log    ✓ Contraseña cambiada y verificada exitosamente    level=INFO

TC-AUTH-013 Recuperación contraseña con respuesta incorrecta es rechazada
    [Documentation]    RF-016 — Respuesta incorrecta debe retornar HTTP 400
    [Tags]    AUTH    Alta    Funcional    Seguridad    TC-AUTH-013
    &{body}=    Create Dictionary
    ...    email=${ADMIN_EMAIL}
    ...    security_answer=respuesta_falsa_xyz
    ...    new_password=HackerPass123!
    ${resp}=    POST Json    /api/auth/reset-password    ${body}
    Response Should Have Status    ${resp}    400
    ${detail}=    Get From Dictionary    ${resp.json()}    detail
    Should Contain    ${detail}    incorrecta
    Log    ✓ HTTP 400: respuesta de seguridad incorrecta    level=INFO

*** Keywords ***

Setup Suite AUTH
    Log    === Iniciando Suite AUTH ===    level=INFO
    Create API Session
    Register Test User
    ${token}=    Get Admin Token
    Set Suite Variable    ${SUITE_TOKEN}    ${token}
    Create Directory    ${SCREENSHOTS_DIR}

Teardown Suite AUTH
    Log    === Suite AUTH completada ===    level=INFO
    Run Keyword And Ignore Error    Delete All Sessions
