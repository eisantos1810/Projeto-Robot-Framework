*** Settings ***
Documentation   Documentação da API: https://fakerestapi.azurewebsites.net/swagger/ui/index#!/Books
Library         RequestsLibrary
Library         Collections

*** Variable ***
####${URL_API}      https://fakerestapi.azurewebsites.net/api/
${URL_API}      https://fakerestapi.azurewebsites.net/api/v1
&{BOOK_15}      ID=15
...             Title=Book 15
...             PageCount=1500
&{BOOK_201}     ID=201
...             Title=Book 201
...             Description=XXX201
...             PageCount=1555
...             Excerpt=AAA201
...             PublishDate=2022-01-05T20:09:37.2641031+00:00
&{BOOK_200}     ID=200
...             Title=Book 200
...             Description=XXX200
...             PageCount=1555
...             Excerpt=AAA200
...             PublishDate=2022-02-05T20:09:37.2641031+00:00

*** Keywords ***
####SETUP E TEARDOWNS
Conectar a minha API
    Create Session    fakeAPI    ${URL_API}
    ${HEADERS}     Create Dictionary    content-type=application/json
    Set Suite Variable    ${HEADERS}

#### Ações
Requisitar todos os livros
####    ${RESPOSTA}    Get Request    fakeAPI    Books
    ${RESPOSTA}    Get On Session    fakeAPI    Books   expected_status=any
    Log            ${RESPOSTA.text}
    Set Test Variable    ${RESPOSTA}

Requisitar o livro "${ID_LIVRO}"
####    ${RESPOSTA}    Get Request    fakeAPI    Books/${ID_LIVRO}
    ${RESPOSTA}    Get On Session    fakeAPI    Books/${ID_LIVRO}   expected_status=any
    Log            ${RESPOSTA.text}
    Set Test Variable    ${RESPOSTA}

Cadastrar um novo livro
####    ${RESPOSTA}    Post Request   fakeAPI    Books
    ${RESPOSTA}    Post On Session   fakeAPI    Books       expected_status=any
    ...                           data={"id": ${BOOK_201.ID},"title": "${BOOK_201.Title}","description": "${BOOK_201.Description}","pageCount": ${BOOK_201.PageCount},"excerpt": "${BOOK_201.Excerpt}","publishDate": "${BOOK_201.PublishDate}"}
    ...                           headers=${HEADERS}
    Log            ${RESPOSTA.text}
    Set Test Variable    ${RESPOSTA}

Alterar um livro
####    ${RESPOSTA}    Put Request   fakeAPI    Books
    ${RESPOSTA}    Put On Session   fakeAPI    Books       expected_status=any
    ...                           data={"id": ${BOOK_200.ID},"title": "${BOOK_200.Title}","description": "${BOOK_200.Description}","pageCount": ${BOOK_200.PageCount},"excerpt": "${BOOK_200.Excerpt}","publishDate": "${BOOK_200.PublishDate}"}
    ...                           headers=${HEADERS}
    Log            ${RESPOSTA.text}
    Set Test Variable    ${RESPOSTA}

#### Conferências
Conferir o status code
    [Arguments]      ${STATUSCODE_DESEJADO}
    Should Be Equal As Strings    ${RESPOSTA.status_code}    ${STATUSCODE_DESEJADO}

Conferir o reason
    [Arguments]    ${REASON_DESEJADO}
    Should Be Equal As Strings    ${RESPOSTA.reason}     ${REASON_DESEJADO}

Conferir se retorna uma lista com "${QTDE_LIVROS}" livros
    Length Should Be      ${RESPOSTA.json()}     ${QTDE_LIVROS}

Conferir se retorna todos os dados corretos do livro 15
    Dictionary Should Contain Item    ${RESPOSTA.json()}    id              ${BOOK_15.ID}
    Dictionary Should Contain Item    ${RESPOSTA.json()}    title           ${BOOK_15.Title}
    Dictionary Should Contain Item    ${RESPOSTA.json()}    pageCount       ${BOOK_15.PageCount}
    Should Not Be Empty    ${RESPOSTA.json()["description"]}
    Should Not Be Empty    ${RESPOSTA.json()["excerpt"]}
    Should Not Be Empty    ${RESPOSTA.json()["publishDate"]}

Conferir se retorna todos os dados cadastrados para o novo livro
    Dictionary Should Contain Item    ${RESPOSTA.json()}    id              ${BOOK_201.ID}
    Dictionary Should Contain Item    ${RESPOSTA.json()}    title           ${BOOK_201.Title}
    Dictionary Should Contain Item    ${RESPOSTA.json()}    pageCount       ${BOOK_201.PageCount}
    Should Not Be Empty    ${RESPOSTA.json()["description"]}
    Should Not Be Empty    ${RESPOSTA.json()["excerpt"]}
    Should Not Be Empty    ${RESPOSTA.json()["publishDate"]}