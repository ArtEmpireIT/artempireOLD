/* jshint indent: 1 */

module.exports = function(sequelize, DataTypes) {
	return sequelize.define('referencia_bibliografica', {
		id_referencia_bibliografica: {
			type: DataTypes.INTEGER,
			allowNull: false,
			defaultValue: "nextval(id_referencia_bibliografica::regclass)",
			primaryKey: true
		},
		isbn: {
			type: DataTypes.STRING,
			allowNull: true
		},
		doi: {
			type: DataTypes.STRING,
			allowNull: true
		},
		autores: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fecha: {
			type: DataTypes.DATE,
			allowNull: true
		},
		paginas: {
			type: DataTypes.STRING,
			allowNull: true
		},
		titulo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		nombre_tipo: {
			type: DataTypes.STRING,
			allowNull: true
		},
		fk_url_id: {
			type: DataTypes.INTEGER,
			allowNull: true,
			references: {
				model: 'url',
				key: 'id_url'
			}
		}
	}, {
		tableName: 'referencia_bibliografica',
		timestamps: false
	});
};
