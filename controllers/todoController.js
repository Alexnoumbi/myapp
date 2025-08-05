const Todo = require('../models/Todo');

// Créer une nouvelle tâche
exports.createTodo = async (req, res) => {
    try {
        const newTodo = new Todo({
            text: req.body.text
        });
        const savedTodo = await newTodo.save();
        res.status(201).json(savedTodo);
    } catch (err) {
        res.status(500).json({ error: 'Erreur lors de la création de la tâche' });
    }
};

// Obtenir toutes les tâches
exports.getTodos = async (req, res) => {
    try {
        const todos = await Todo.find();
        res.status(200).json(todos);
    } catch (err) {
        res.status(500).json({ error: 'Erreur lors de la récupération des tâches' });
    }
};

// Mettre à jour une tâche
exports.updateTodo = async (req, res) => {
    try {
        const updatedTodo = await Todo.findByIdAndUpdate(req.params.id, req.body, { new: true });
        if (!updatedTodo) {
            return res.status(404).json({ error: 'Tâche non trouvée' });
        }
        res.status(200).json(updatedTodo);
    } catch (err) {
        res.status(500).json({ error: 'Erreur lors de la mise à jour de la tâche' });
    }
};

// Supprimer une tâche
exports.deleteTodo = async (req, res) => {
    try {
        const deletedTodo = await Todo.findByIdAndRemove(req.params.id);
        if (!deletedTodo) {
            return res.status(404).json({ error: 'Tâche non trouvée' });
        }
        res.status(200).json({ message: 'Tâche supprimée avec succès' });
    } catch (err) {
        res.status(500).json({ error: 'Erreur lors de la suppression de la tâche' });
    }
};