import gym
import numpy as np

def get_qval(env, Q, s):
    if s not in Q:
        tmp = []
        for i in range(env.action_space.n):
            tmp.append(0)
        Q[s] = tmp
    return Q[s]

def get_state (env, observation):
    env_low = env.observation_space.low
    env_high = env.observation_space.high
    env_dx = (env_high - env_low) / 40
    
    a = int((observation[0] - env_low[0])/env_dx[0])
    b = int((observation[1] - env_low[1])/env_dx[1])
    return (a, b)

def play(env, policy):
    obs = env.reset()

    while True:
        env.render()
        s = get_state(env, obs)
        action = np.argmax(get_qval(env, policy, s))
        obs, _, done, _ = env.step(action)
        if done:
            break

    return 0

def train(env, MAX_ITER):
    gamma = 1.0
    min_alpha = 0.003
    initial_alpha = 1.0
    eps = 0.02

    Q = {}
    for i_episode in range(MAX_ITER):
        observation = env.reset()
        alpha = max(min_alpha, initial_alpha * (0.85 ** (i_episode//100)))
        total_reward = 0

        while True:
            s = get_state(env, observation)

            # Does not find the best path without this. Overfits
            if np.random.uniform(0,1) < eps:
                action = np.random.choice(env.action_space.n)
            else:
                logits = np.exp(get_qval(env, Q, s))
                probs = logits/np.sum(logits)
                action = np.random.choice(env.action_space.n, p=probs)

            observation, r, done, _ = env.step(action)
            s_ = get_state(env, observation)
            total_reward += r

            Q[s][action] = Q[s][action] + alpha * (r + gamma * np.max(get_qval(env, Q, s_)) - Q[s][action])

            if done:
                break
        if i_episode%100 == 0:
            print("Iteration #%d - Total reward = %d Q size = %d" %(i_episode+1, total_reward, len(Q)))

    return Q

def main():
    env = gym.make('MountainCar-v0')
    env.seed(0)
    np.random.seed(0)

    Q = train(env, 1500)
    play(env, Q)

if __name__ == '__main__':
    main()
