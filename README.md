# Auction Smart Contract

Smart Contract для децентралізованого аукціону на Ethereum.

## Можливості

- Організатор створює аукціон під час деплою контракту.
- Задаються назва лоту, мінімальна ставка та час завершення.
- Користувачі роблять ставки в ETH.
- Нова ставка повинна бути більшою за поточну найвищу ставку.
- Аукціон можна завершити після закінчення часу або вручну власником.
- Переможець визначається за найбільшою ставкою.
- Організатор може скасувати аукціон до завершення.
- Користувачі можуть забрати повернення через `withdrawRefund()`.
- Власник може забрати виграш через `withdrawOwnerBalance()`.

## Запуск у Ganache

1. Відкрити Ganache.
2. Переконатися, що Ganache працює на:

```text
http://127.0.0.1:7545
```

3. У VS Code відкрити термінал у папці `AuctionTruffle`.
4. Скомпілювати контракт:

```powershell
truffle.cmd compile
```

5. Розгорнути контракт у Ganache:

```powershell
truffle.cmd migrate --network development
```

Якщо потрібно перерозгорнути контракт:

```powershell
truffle.cmd migrate --reset --network development
```

## Тести

```powershell
truffle.cmd test
```

## Параметри деплою

Параметри аукціону знаходяться у файлі `migrations/2_deploy_auction.js`:

```javascript
const itemName = "Laptop";
const minimumBid = web3.utils.toWei("0.1", "ether");
const durationInSeconds = 3600;
```

Їх можна змінити перед деплоєм.
