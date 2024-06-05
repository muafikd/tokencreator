<template>
    <div class="navbar">
        <h4>Address:</h4>
        <p>{{ $store.state.address }}</p>
        <button @click="connectWallet" class="btn connect-btn">Connect wallet</button>
    </div>
</template>

<script>
import { mapActions } from 'vuex'
export default {
    name: 'navbar-component',
    methods: {
        ...mapActions({
            connectWallet: "connectWallet",
        }),
    },
};
</script>

<style scoped>
.navbar {
    background-color: #f8f9fa;
    padding: 10px 20px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    border-bottom: 1px solid #e0e0e0;
}

.navbar h4 {
    margin: 0;
    color: #333;
    font-size: 18px;
}

.navbar p {
    margin: 0 10px;
    color: #666;
    font-size: 16px;
}

.btn.connect-btn {
    padding: 8px 16px;
    background-color: #007bff;
    color: white;
    border: none;
    border-radius: 4px;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.btn.connect-btn:hover {
    background-color: #0056b3;
}
</style>